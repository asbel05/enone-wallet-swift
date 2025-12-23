//
//  ExchangeRateRepositoryProtocol.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

protocol ExchangeRateRepositoryProtocol {
    func getRate(from: String, to: String) async throws -> ExchangeRate
    func convert(amount: Double, from: String, to: String) async throws -> Double
    func refreshRates() async throws
    func getLastUpdate() async throws -> Date?
}
