//
//  ExchangeRateCache.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//  Refactorizado: 23/12/25 - Cache simple con TTL de 1 hora
//

import Foundation

final class ExchangeRateCache: CacheStorage {
    
    static let shared = ExchangeRateCache()
    
    private let defaults = UserDefaults.standard
    
    static let cacheExpirationMinutes = 60
    
    private enum Keys {
        static let usdToPen = "exchange_rate_usd_pen"
        static let penToUsd = "exchange_rate_pen_usd"
        static let timestamp = "exchange_rate_timestamp"
        static let shortTTLExpiry = "exchange_rate_short_ttl_expiry"
    }
    
    private init() {}

    func save(usdToPen: Double, penToUsd: Double) {
        defaults.set(usdToPen, forKey: Keys.usdToPen)
        defaults.set(penToUsd, forKey: Keys.penToUsd)
        defaults.set(Date(), forKey: Keys.timestamp)
        print("💾 ExchangeRateCache: Guardado USD→PEN: \(usdToPen), PEN→USD: \(penToUsd)")
    }
    
    func saveWithShortTTL(usdToPen: Double, penToUsd: Double, expireInMinutes: Int) {
        defaults.set(usdToPen, forKey: Keys.usdToPen)
        defaults.set(penToUsd, forKey: Keys.penToUsd)
        // Para TTL corto, usamos una key separada
        defaults.set(Date().addingTimeInterval(Double(expireInMinutes) * 60), forKey: Keys.shortTTLExpiry)
        defaults.set(Date(), forKey: Keys.timestamp)
        print("💾 ExchangeRateCache: Guardado con TTL corto (\(expireInMinutes) min)")
    }

    func getUsdToPen() -> Double? {
        guard !isExpired() else { return nil }
        let rate = defaults.double(forKey: Keys.usdToPen)
        return rate > 0 ? rate : nil
    }
    
    func getPenToUsd() -> Double? {
        guard !isExpired() else { return nil }
        let rate = defaults.double(forKey: Keys.penToUsd)
        return rate > 0 ? rate : nil
    }
    
    func getRates() -> (usdToPen: Double, penToUsd: Double)? {
        guard let usd = getUsdToPen(), let pen = getPenToUsd() else {
            return nil
        }
        return (usd, pen)
    }

    /// Verifica si el cache expiró (expira en la siguiente hora en punto, o antes si tiene TTL corto)
    func isExpired() -> Bool {
        guard let timestamp = defaults.object(forKey: Keys.timestamp) as? Date else {
            return true
        }
        
        // Primero verificar si hay TTL corto activo (fallback mode)
        if let shortExpiry = defaults.object(forKey: Keys.shortTTLExpiry) as? Date {
            if Date() >= shortExpiry {
                // TTL corto expiró, limpiar la key
                defaults.removeObject(forKey: Keys.shortTTLExpiry)
                return true
            }
            // TTL corto aún válido
            return false
        }
        
        // Sin TTL corto, usar lógica de hora en punto
        let calendar = Calendar.current
        let timestampHour = calendar.dateInterval(of: .hour, for: timestamp)?.start ?? timestamp
        let currentHour = calendar.dateInterval(of: .hour, for: Date())?.start ?? Date()
        
        return currentHour > timestampHour
    }
    
    func getTimestamp() -> Date? {
        return defaults.object(forKey: Keys.timestamp) as? Date
    }
    
    func remainingMinutes() -> Int {
        guard let timestamp = defaults.object(forKey: Keys.timestamp) as? Date else {
            return 0
        }
        
        let calendar = Calendar.current
        // Siguiente hora en punto
        guard let nextHour = calendar.date(byAdding: .hour, value: 1, to: calendar.dateInterval(of: .hour, for: timestamp)?.start ?? timestamp) else {
            return 0
        }
        
        let remaining = nextHour.timeIntervalSince(Date()) / 60
        return max(0, Int(remaining))
    }

    func clear() {
        defaults.removeObject(forKey: Keys.usdToPen)
        defaults.removeObject(forKey: Keys.penToUsd)
        defaults.removeObject(forKey: Keys.timestamp)
        defaults.removeObject(forKey: Keys.shortTTLExpiry)
        print("ExchangeRateCache: Cache limpiado")
    }
}
