//
//  File.swift
//  
//
//  Created by Claudio Barbera on 23/10/21.
//

import Foundation
import Security

protocol Keychain {
    func write(privateKey valueKey: String, for tag: String) throws
    func read(for tag: String) -> SecKey?
    func contains(tag: String) -> Bool
}

class KeychainWrapper: Keychain {

    init() { }
    
    /// Create a private a cryptographic key with a base64 string representation
    func write(privateKey valueKey: String, for tag: String) throws {
        
        guard let keyTag = tag.data(using: .utf8) else {  throw KeychainWrapperError.invalidTagError }
        
        let stripped = valueKey.replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "").replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "")

        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA, // RSA
            kSecAttrKeyClass: kSecAttrKeyClassPrivate, // Private
        ] as NSDictionary
        
        guard let keyData = Data(base64Encoded: stripped, options: .ignoreUnknownCharacters) else { throw KeychainWrapperError.base64EncodeError }
        
        guard let key = SecKeyCreateWithData(keyData as NSData, attributes, nil) else { throw KeychainWrapperError.createKeyError }
        
        let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: keyTag,
                                       kSecValueRef as String: key]
        
        let status = SecItemAdd(addquery as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainWrapperError.addError(error: status) }
    }
    
    func read(for tag: String) -> SecKey? {
        
        let keyTag = tag.data(using: .utf8)!
        
        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: keyTag,
                                       kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                       kSecReturnRef as String: true]
        
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return (item as! SecKey)
    }
    
    func remove(for tag: String) throws {
        
        guard let keyTag = tag.data(using: .utf8) else {
            throw KeychainWrapperError.invalidTagError
        }
        
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: keyTag,
                                       kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                       kSecReturnRef as String: true]
 
        
        let status = SecItemDelete(query as CFDictionary)
   
        guard status == errSecSuccess else {
            throw KeychainWrapperError.removeError(error: status)
        }
    }
    
    func contains(tag: String) -> Bool {
        
        guard read(for: tag) != nil else { return false }
        return true
    }
}

enum KeychainWrapperError: Error {
    case invalidTagError
    case createKeyError
    case base64EncodeError
    case addError(error: OSStatus)
    case removeError(error: OSStatus)
}
