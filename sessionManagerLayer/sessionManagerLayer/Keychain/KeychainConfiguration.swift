//
//  KeychainConfiguration.swift
//  sessionManagerLayer
//
//  Created by Rodrigo Oliveira on 8/5/21.
//

import Foundation

struct KeychainConfiguration {
    
    // MARK: - Attributes
    private let dictionary = Bundle.main.infoDictionary
    let accessGroup: String? = nil
    
    // MARK: - Custom methods
    
    private func getBundle() -> String {
        guard let dictionary = dictionary,
              let value = dictionary["CFBundleIdentifier"] as? String
        else { return "" }
        
        return value
    }
    
    public func serviceUserType() -> String {
        return "\(getBundle())UserTypeService"
    }
    
    public func serviceToken() -> String {
        return "\(getBundle())TokenService"
    }
    
    public func accountName() -> String {
        return "\(getBundle())Account"
    }
    
}
