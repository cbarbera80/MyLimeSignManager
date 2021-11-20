//
//  KeyPair.swift
//  DemoApp
//
//  Created by Claudio Barbera on 25/10/21.
//

import Foundation

struct KeyPair: Decodable {
    let privateKey: String
    let publicKey: String
    
    enum CodingKeys: String, CodingKey {
        case privateKey = "private_key"
        case publicKey = "certificate"
    }
}
