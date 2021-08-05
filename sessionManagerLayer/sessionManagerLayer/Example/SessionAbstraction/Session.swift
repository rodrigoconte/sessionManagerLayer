//
//  Session.swift
//  sessionManagerLayer
//
//  Created by Rodrigo Oliveira on 8/5/21.
//

import Foundation

final class Session {
    
    // MARK: - Attributes
    
    static let shared = Session()
    private let session = SessionManager.shared
    
    // MARK: - Life Cycle
    
    private init() {}
    
    // MARK: - Custom methods
    
    func save(_ data: SessionData) {
        session.saveInfo(data)
    }
    
    func isLogged() -> Bool {
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasRunBefore") {
            guard
                let currentSession = session.getSession(type: SessionData.self),
                let token = currentSession.token else {
                return false
            }
            return !token.isEmpty
        }
        
        userDefaults.set(true, forKey: "hasRunBefore")
        session.deleteAllData(type: SessionData.self)
        return false
    }
    
    func logout() {
        session.deleteAllData(type: SessionData.self)
    }
    
    func getData() -> SessionData? {
        session.getSession(type: SessionData.self)
    }
    
}
