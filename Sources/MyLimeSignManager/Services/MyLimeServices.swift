//
//  File.swift
//  
//
//  Created by Claudio Barbera on 23/10/21.
//

import Foundation

protocol SignService {
    func getPrivateKey(completion: @escaping (KeyPair?, Error?) -> Void)
}

class MyLimeServices: SignService {
    
    var network: DataProviderable
    
    init(withEnvironment environment: Environment, auth: Auth) {
        network = Networking(withEnvironment: environment, auth: auth)
    }
    
    func getPrivateKey(completion: @escaping (KeyPair?, Error?) -> Void) {
        
        network.execute(Endpoint.getSignatureKey, of: KeyPair.self) { res in
            switch res {
            case .success(let wrappedData):
                completion(wrappedData, nil)
            case .failure(let err):
                completion(nil, err)
            }
        }
    }
}
