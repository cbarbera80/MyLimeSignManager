//
//  MyLimeSignManager.swift
//
//
//  Created by Claudio Barbera on 23/10/21.
//

import Security
import Foundation
import CryptoKit

public enum MyLimeSignError: Error {
    case keyNotFound
    case invalidData
    case authNotProvided
    case genericError
    case unsupportedAlgorithm
    case invalidKey
    case invalidJSON
    case invalidSignature
}   

public struct Auth {
    let token: String
    let client: String
    let uid: String
    
    public init(token: String, client: String, uid: String) {
        self.token = token
        self.client = client
        self.uid = uid
    }
}

public class MyLimeSignManager {
  
    deinit {
        print("Deinit MyLimeSignManager")
    }
    
    let services: SignService
    let keychain = KeychainWrapper()
    private let tag: String
    let jsonEncoder: JSONEncoder
    
    public init?(baseURL: URL, token: String?, client: String?, uid: String?, id: Int?) {
        
        guard let token = token, let client = client, let uid = uid, let id = id else {
            return nil
        }

        tag = "com.mylime.secure.keychain.securekey.\(id)"
        jsonEncoder = JSONEncoder()
        services = MyLimeServices(withEnvironment: .init(baseUrl: baseURL), auth: .init(token: token, client: client, uid: uid))
    }
    
    public func sign(data: Data) throws -> MlSignature {
    
        // Make hash from body
        let dataHash = SHA256.hash(data: data)
        
        // and format it as string
        let hashString = dataHash.compactMap { String(format: "%02x", $0) }.joined()
        let nonce = String(describing: arc4random())
        let timestamp = String(describing: Date().timeIntervalSince1970)
        
        let body = MlSignature(timestamp: timestamp, body: hashString, nonce: nonce)
     
        guard let privateKeyString = keychain.read(for: tag) else { throw MyLimeSignError.keyNotFound }
        guard let jsonData = try? JSONEncoder().encode(body) else { throw MyLimeSignError.invalidJSON }
        
        // Create signature
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
        var error: Unmanaged<CFError>?
        
        guard SecKeyIsAlgorithmSupported(privateKeyString, .sign, algorithm) else {
            throw MyLimeSignError.unsupportedAlgorithm
        }
        
        guard let signatureTest = SecKeyCreateSignature(privateKeyString,
                                                    algorithm,
                                                    jsonData as CFData,
                                                    &error) as Data? else {
                                                        throw error!.takeRetainedValue() as Error }
        
        let b64Signature = signatureTest.base64EncodedString()
    
        return MlSignature(timestamp: timestamp, body: b64Signature, nonce: nonce)
    }
    
    /// Remove previously saved private key from keychain
    public func removeKeychain() throws {
        try keychain.remove(for: tag)
    }
    
    /// Initialize keychain. If keychain already contains a private key return it, else call API to get a valid private key to store in keychain
    public func initKeychain(completion: @escaping (MyLimeSignError?) -> Void) {
        
        guard !keychain.contains(tag: tag) else {
            completion(nil)
            return
        }
        
        services.getPrivateKey { [weak self] pKey, error in
            guard let self = self else {
                completion(MyLimeSignError.genericError)
                return
            }
            
            if let key = pKey {
                try? self.keychain.write(privateKey: key.privateKey, for: self.tag)
                completion(nil)
            } else {
                completion(MyLimeSignError.keyNotFound)
            }
            
        }
    }
}
