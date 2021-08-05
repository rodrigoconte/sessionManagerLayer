//
//  SessionData.swift
//  sessionManagerLayer
//
//  Created by Rodrigo Oliveira on 8/5/21.
//

import Foundation

final class SessionData: Codable {
    
    var token: String?
    var user: User?
    
    private enum CodingKeys: String, CodingKey {
        case
        token = "access_token",
        user
    }
}
