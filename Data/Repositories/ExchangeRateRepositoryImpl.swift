//
//  ExchangeRateRepositoryImpl.swift
//  enone
//
//  Created by Asbel on 19/12/25.
//

import Foundation

final class ExchangeRateRepositoryImpl: ExchangeRateRepositoryProtocol {
    
    private let dataSource: ExchangeRateDataSource
    
    init(dataSource: ExchangeRateDataSource = ExchangeRateDataSource()) {
        self.dataSource = dataSource
    }
    
    func getRate(from baseCurrency: String, to targetCurrency: String) async throws -> ExchangeRate {
        return try await dataSource.getRate(from: baseCurrency, to: targetCurrency)
    }
    
    func convert(amount: Double, from baseCurrency: String, to targetCurrency: String) async throws -> Double {
        let rate = try await getRate(from: baseCurrency, to: targetCurrency)
        return rate.convert(amount: amount)
    }
    
    func refreshRates() async throws {
        try await dataSource.forceRefresh()
    }
    
    func getLastUpdate() async throws -> Date? {
        return ExchangeRateCache.shared.getTimestamp()
    }
}
