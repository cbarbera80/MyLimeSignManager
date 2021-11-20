//
//  SignedData.swift
//  DemoApp
//
//  Created by Claudio Barbera on 25/10/21.
//

import Foundation

public struct MlSignature: Encodable {
    
    public let timestamp: String
    public let body: String
    public let nonce: String
    
}
