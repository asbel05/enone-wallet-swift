//
//  CacheManager.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

/// Fachada central para acceder a todos los módulos de cache
/// Cada módulo maneja un dominio específico de datos
final class CacheManager {
    
    static let shared = CacheManager()

    let profile = ProfileCache.shared
    
    let security = SecurityCache.shared
    
    let exchangeRate = ExchangeRateCache.shared
    
    let preferences = PreferencesCache.shared
    
    private init() {}

    /// Limpia caches de datos del usuario (no limpia exchange rate ni preferences)
    func clearAll() {
        profile.clear()
        security.clear()

        print("CacheManager: User caches cleared (profile, security)")
    }

    /// No se utiliza
    func clearEverything() {
        profile.clear()
        security.clear()
        exchangeRate.clear()
        preferences.resetToDefaults()
        
        print("CacheManager: Everything cleared including preferences and exchange rate")
    }
}
