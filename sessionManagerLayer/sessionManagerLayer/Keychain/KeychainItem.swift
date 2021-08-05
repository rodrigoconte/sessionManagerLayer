//
//  KeychainItem.swift
//  sessionManagerLayer
//
//  Created by Rodrigo Oliveira on 8/5/21.
//

import Foundation

struct KeychainItem<T: Codable> {
    
    // MARK: Attributes
    
    private let configuration = KeychainConfiguration()
    private(set) var type: T.Type
    
    enum KeychainError: Error {
        case noToken
        case unexpectedTokenData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    // MARK: - Life cycle
    
    init(type: T.Type) {
        self.type = type
    }
    
    // MARK: Keychain access
    
    @discardableResult func readItem() throws -> T {
        /*
         Build a query to find the Token that matches the service, account and
         access group.
         */
        var query = KeychainItem.keychainQuery(withService: configuration.serviceToken(),
                                               account: configuration.accountName(),
                                               accessGroup: configuration.accessGroup)
        
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noToken }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Parse the Item string from the query result.
        guard let existingItem = queryResult as? [String : AnyObject],
            let itemData = existingItem[kSecValueData as String] as? Data,
            let item = String(data: itemData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedTokenData
        }
        
        let jsonData = Data(item.utf8)
        let loginData = try JSONDecoder().decode(T.self, from: jsonData)
        return loginData
    }
    
    func saveItem(_ loginData: T) throws {
        let jsonData = try JSONEncoder().encode(loginData)
        
        guard
            let jsonString = String(data: jsonData, encoding: .utf8),
            let data = jsonString.data(using: .utf8) else {
             throw KeychainError.unexpectedTokenData
        }
        
        do {
            // Check for an existing item in the keychain.
            try readItem()
            
            // Update the existing item with the new Item.
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = data as AnyObject?
            
            let query = KeychainItem.keychainQuery(withService: configuration.serviceToken(),
                                                   account: configuration.accountName(),
                                                   accessGroup: configuration.accessGroup)
            
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        } catch KeychainError.noToken {
            /*
             No Item was found in the keychain. Create a dictionary to save
             as a new keychain item.
             */
            var newToken = KeychainItem.keychainQuery(
                withService: configuration.serviceToken(),
                account: configuration.accountName(),
                accessGroup: configuration.accessGroup)
            
            newToken[kSecValueData as String] = data as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newToken as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
    
    static func deleteAll() throws {
        let secItemClasses =  [kSecClassGenericPassword]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            let status = SecItemDelete(spec)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
}
