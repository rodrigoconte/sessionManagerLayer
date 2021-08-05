//
//  SessionManager.swift
//  sessionManagerLayer
//
//  Created by Rodrigo Oliveira on 8/5/21.
//

import Foundation

public final class SessionManager {
    
    // MARK: - Attributes
    
    private static var instance: SessionManager?
    public class var shared : SessionManager {
        guard let instance = self.instance else {
            let instance = SessionManager()
            self.instance = instance
            return instance
        }
        return instance
    }
    
    // MARK: - Life cycle
    
    private init() {}
    
    public class func destroy() {
        instance = nil
    }
    
    // MARK: - Custom methods
    
    @discardableResult public func saveInfo<T: Codable>(_ data: T) -> Bool {
        // Check if we need to update an existing item or create a new one.
        do {
            // This is a new account, create a new keychain item with the account name.
            let dataItem = KeychainItem(type: T.self)
            
            // Save data for the new item.
            try dataItem.saveItem(data)
            return true
        } catch {
            #if DEBUG
            print("Error updating keychain - \(error)")
            #endif
            return false
        }
    }
    
    public func getSession<T: Codable>(type: T.Type) -> T? {
        do {
            let dataItem = KeychainItem(type: type)
            let data = try dataItem.readItem()
            
            return data
        } catch {
            return nil
        }
    }
    
    @discardableResult public func deleteAllData<T: Codable>(type: T.Type) -> Bool {
        do {
            try KeychainItem<T>.deleteAll()
            SessionManager.destroy()
            return true
        } catch {
            #if DEBUG
            print("Error reset keychain")
            #endif
            return false
        }
    }
}
