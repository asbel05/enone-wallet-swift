//
//  GetExchangeRateUseCase.swift
//  enone
//
//  Created by Asbel on 19/12/25.
//

import Foundation

struct GetExchangeRateUseCase {
    private let repository: ExchangeRateRepositoryProtocol
    
    init(repository: ExchangeRateRepositoryProtocol = ExchangeRateRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute(from base: String, to target: String) async throws -> ExchangeRate {
        return try await repository.getRate(from: base, to: target)
    }
    
    func refreshRates() async throws {
        try await repository.refreshRates()
    }
}
