//
//  KeychainManager.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation
import Security

final class KeychainManager {
    
    static let shared = KeychainManager()
    
    private let service = "com.enone.app"
    
    private enum Keys {
        static let activeCard = "active_card_data"
    }
    
    private init() {}
    
    struct SecureCard: Codable {
        let maskedNumber: String
        let brand: String?
        let holderName: String?
        let expiryDate: String?
    }
    
    func saveActiveCard(_ card: SecureCard) -> Bool {
        guard let data = try? JSONEncoder().encode(card) else {
            return false
        }

        deleteActiveCard()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: Keys.activeCard,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getActiveCard() -> SecureCard? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: Keys.activeCard,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let card = try? JSONDecoder().decode(SecureCard.self, from: data) else {
            return nil
        }
        
        return card
    }
    
    @discardableResult
    func deleteActiveCard() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: Keys.activeCard
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    func clearAll() {
        deleteActiveCard()
    }
}
