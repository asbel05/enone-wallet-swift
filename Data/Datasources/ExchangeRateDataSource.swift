//
//  ExchangeRateDataSource.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation
import Supabase

final class ExchangeRateDataSource {
    
    private let cache = ExchangeRateCache.shared
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseClientProvider.shared.client) {
        self.client = client
    }

    func getRate(from baseCurrency: String, to targetCurrency: String) async throws -> ExchangeRate {
        if let cachedRate = getCachedRate(from: baseCurrency, to: targetCurrency) {
            print("ExchangeRate: Usando cache local para \(baseCurrency)→\(targetCurrency)")
            return cachedRate
        }
        
        // Consulta Supabase (función que maneja race conditions)
        print("🔍 ExchangeRate: Cache local expirado, consultando Supabase...")
        let dbResponse = try await checkSupabaseRate(from: baseCurrency, to: targetCurrency)
        
        // Si Supabase tiene rate válido, usarlo
        if dbResponse.success && !dbResponse.needsRefresh {
            saveToLocalCache(rate: dbResponse.rate, from: baseCurrency, to: targetCurrency)
            print("✅ ExchangeRate: Usando Supabase para \(baseCurrency)→\(targetCurrency)")
            return ExchangeRate(
                id: nil,
                baseCurrency: baseCurrency,
                targetCurrency: targetCurrency,
                rate: dbResponse.rate,
                source: .database,
                fetchedAt: dbResponse.fetchedAt
            )
        }
        
        // 3. Supabase indica que necesita refresh - llamar API
        print("🌐 ExchangeRate: Supabase expirado, llamando API...")
        return try await fetchFromAPIAndSave(from: baseCurrency, to: targetCurrency)
    }
    
    func forceRefresh() async throws {
        print("🔄 ExchangeRate: Forzando actualización...")
        cache.clear()
        _ = try await fetchFromAPIAndSave(from: "USD", to: "PEN")
    }
    
    // MARK: - Cache Local (UserDefaults)
    
    private func getCachedRate(from base: String, to target: String) -> ExchangeRate? {
        guard let rates = cache.getRates() else { return nil }
        
        let rate: Double
        if base == "USD" && target == "PEN" {
            rate = rates.usdToPen
        } else if base == "PEN" && target == "USD" {
            rate = rates.penToUsd
        } else {
            return nil
        }
        
        return ExchangeRate(
            id: nil,
            baseCurrency: base,
            targetCurrency: target,
            rate: rate,
            source: .api,
            fetchedAt: cache.getTimestamp().map { ISO8601DateFormatter().string(from: $0) }
        )
    }
    
    private func saveToLocalCache(rate: Double, from base: String, to target: String) {
        if base == "USD" && target == "PEN" {
            let penToUsd = 1.0 / rate
            cache.save(usdToPen: rate, penToUsd: penToUsd)
        } else if base == "PEN" && target == "USD" {
            let usdToPen = 1.0 / rate
            cache.save(usdToPen: usdToPen, penToUsd: rate)
        }
    }
    
    /// Guarda en cache con TTL corto (5 min) para reintentar API pronto
    private func saveToLocalCacheWithShortTTL(rate: Double, from base: String, to target: String) {
        if base == "USD" && target == "PEN" {
            let penToUsd = 1.0 / rate
            cache.saveWithShortTTL(usdToPen: rate, penToUsd: penToUsd, expireInMinutes: 5)
        } else if base == "PEN" && target == "USD" {
            let usdToPen = 1.0 / rate
            cache.saveWithShortTTL(usdToPen: usdToPen, penToUsd: rate, expireInMinutes: 5)
        }
    }
    
    // MARK: - Supabase RPC
    
    private struct SupabaseRateResponse: Decodable {
        let success: Bool
        let source: String?
        let rate: Double?
        let fetchedAt: String?
        let needsRefresh: Bool?
        let error: String?
        
        enum CodingKeys: String, CodingKey {
            case success
            case source
            case rate
            case fetchedAt = "fetched_at"
            case needsRefresh = "needs_refresh"
            case error
        }
    }
    
    private struct RPCResponse {
        let success: Bool
        let rate: Double
        let fetchedAt: String?
        let needsRefresh: Bool
    }
    
    private func checkSupabaseRate(from base: String, to target: String) async throws -> RPCResponse {
        struct RPCParams: Encodable {
            let p_base_currency: String
            let p_target_currency: String
        }
        
        do {
            let response: SupabaseRateResponse = try await client
                .rpc("get_or_update_exchange_rate", params: RPCParams(
                    p_base_currency: base,
                    p_target_currency: target
                ))
                .execute()
                .value
            
            return RPCResponse(
                success: response.success,
                rate: response.rate ?? 0,
                fetchedAt: response.fetchedAt,
                needsRefresh: response.needsRefresh ?? true
            )
        } catch {
            print("⚠️ ExchangeRate: Error en RPC, intentando query directo...")
            return try await checkSupabaseRateDirect(from: base, to: target)
        }
    }
    
    private func checkSupabaseRateDirect(from base: String, to target: String) async throws -> RPCResponse {
        struct DBRate: Decodable {
            let rate: Double
            let fetched_at: String?
        }
        
        let response: [DBRate] = try await client
            .from("exchange_rate_cache")
            .select("rate, fetched_at")
            .eq("base_currency", value: base)
            .eq("target_currency", value: target)
            .execute()
            .value
        
        guard let record = response.first else {
            return RPCResponse(success: false, rate: 0, fetchedAt: nil, needsRefresh: true)
        }
        
        // Verificar si expiró (> 1 hora)
        var needsRefresh = true
        if let fetchedAtString = record.fetched_at {
            let formatter = ISO8601DateFormatter()
            if let fetchedAt = formatter.date(from: fetchedAtString) {
                let ageMinutes = Date().timeIntervalSince(fetchedAt) / 60
                needsRefresh = ageMinutes > 60
            }
        }
        
        return RPCResponse(
            success: true,
            rate: record.rate,
            fetchedAt: record.fetched_at,
            needsRefresh: needsRefresh
        )
    }
    
    private func updateSupabaseRate(base: String, target: String, rate: Double) async throws {
        struct RPCParams: Encodable {
            let p_base_currency: String
            let p_target_currency: String
            let p_new_rate: Double
        }
        
        do {
            let _: SupabaseRateResponse = try await client
                .rpc("get_or_update_exchange_rate", params: RPCParams(
                    p_base_currency: base,
                    p_target_currency: target,
                    p_new_rate: rate
                ))
                .execute()
                .value
            
            print("💾 ExchangeRate: Actualizado en Supabase via RPC \(base)→\(target): \(rate)")
        } catch {
            // Fallback a upsert directo
            try await updateSupabaseRateDirect(base: base, target: target, rate: rate)
        }
    }
    
    private func updateSupabaseRateDirect(base: String, target: String, rate: Double) async throws {
        struct UpsertRate: Encodable {
            let base_currency: String
            let target_currency: String
            let rate: Double
            let source: String
            let fetched_at: String
        }
        
        let data = UpsertRate(
            base_currency: base,
            target_currency: target,
            rate: rate,
            source: "API",
            fetched_at: ISO8601DateFormatter().string(from: Date())
        )
        
        try await client
            .from("exchange_rate_cache")
            .upsert(data, onConflict: "base_currency,target_currency")
            .execute()
        
        print("💾 ExchangeRate: Actualizado en Supabase directo \(base)→\(target): \(rate)")
    }
    
    // MARK: - API Externa
    
    private func fetchFromAPIAndSave(from base: String, to target: String) async throws -> ExchangeRate {
        do {
            // Obtener ambas tasas
            async let usdRateTask = fetchFromAPI(base: "USD", target: "PEN")
            async let penRateTask = fetchFromAPI(base: "PEN", target: "USD")
            
            let usdToPen = try await usdRateTask
            let penToUsd = try await penRateTask
            
            // Guardar en cache local
            cache.save(usdToPen: usdToPen, penToUsd: penToUsd)
            
            // Guardar en Supabase (para otros usuarios)
            try? await updateSupabaseRate(base: "USD", target: "PEN", rate: usdToPen)
            try? await updateSupabaseRate(base: "PEN", target: "USD", rate: penToUsd)
            
            // Retornar la tasa solicitada
            let requestedRate = (base == "USD") ? usdToPen : penToUsd
            
            return ExchangeRate(
                id: nil,
                baseCurrency: base,
                targetCurrency: target,
                rate: requestedRate,
                source: .api,
                fetchedAt: ISO8601DateFormatter().string(from: Date())
            )
        } catch {
            // API falló - usar último rate de Supabase (aunque esté expirado)
            print("⚠️ ExchangeRate: API falló, usando último rate de Supabase...")
            let fallback = try await checkSupabaseRateDirect(from: base, to: target)
            
            if fallback.success && fallback.rate > 0 {
                // Guardar con TTL corto (5 min) para reintentar API pronto
                saveToLocalCacheWithShortTTL(rate: fallback.rate, from: base, to: target)
                
                return ExchangeRate(
                    id: nil,
                    baseCurrency: base,
                    targetCurrency: target,
                    rate: fallback.rate,
                    source: .database,
                    fetchedAt: fallback.fetchedAt
                )
            }
            
            throw ExchangeRateError.rateNotFound
        }
    }
    
    private func fetchFromAPI(base: String, target: String) async throws -> Double {
        guard let url = ExchangeRateAPIConfig.ratesURL(base: base) else {
            throw ExchangeRateError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ExchangeRateError.apiError
        }
        
        let apiResponse = try JSONDecoder().decode(ExchangeRateAPIResponse.self, from: data)
        
        guard let rate = apiResponse.conversionRates[target] else {
            throw ExchangeRateError.rateNotFound
        }
        
        return rate
    }
}

// MARK: - Errors

enum ExchangeRateError: LocalizedError {
    case invalidURL
    case apiError
    case rateNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL de API inválida"
        case .apiError:
            return "Error al obtener tipo de cambio"
        case .rateNotFound:
            return "Tipo de cambio no disponible. Intenta más tarde."
        }
    }
}
