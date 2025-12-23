//
//  SecurityCache.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import Foundation

/// Cache para estado de seguridad (2FA)
/// Almacena el estado de autenticación de dos factores
final class SecurityCache: CacheStorage {
    
    static let shared = SecurityCache()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let twoFactorEnabled = "cache_2fa_enabled"
        static let twoFactorSecret = "cache_2fa_secret"
    }
    
    private init() {}
    
    // MARK: - Two Factor State
    
    struct TwoFactorState {
        let enabled: Bool
        let secret: String?
        
        init(enabled: Bool, secret: String? = nil) {
            self.enabled = enabled
            self.secret = secret
        }
    }
    
    // MARK: - Public Methods
    
    func saveTwoFactorState(enabled: Bool, secret: String?) {
        defaults.set(enabled, forKey: Keys.twoFactorEnabled)
        if let secret = secret {
            defaults.set(secret, forKey: Keys.twoFactorSecret)
        } else {
            defaults.removeObject(forKey: Keys.twoFactorSecret)
        }
    }
    
    func getTwoFactorState() -> TwoFactorState? {
        // Si no existe la key, no hay cache
        guard defaults.object(forKey: Keys.twoFactorEnabled) != nil else {
            return nil
        }
        
        let enabled = defaults.bool(forKey: Keys.twoFactorEnabled)
        let secret = defaults.string(forKey: Keys.twoFactorSecret)
        
        return TwoFactorState(enabled: enabled, secret: secret)
    }
    
    /// Verifica rápidamente si 2FA está habilitado (usa cache)
    var isTwoFactorEnabled: Bool {
        return getTwoFactorState()?.enabled ?? false
    }
    
    func clear() {
        defaults.removeObject(forKey: Keys.twoFactorEnabled)
        defaults.removeObject(forKey: Keys.twoFactorSecret)
    }
}
