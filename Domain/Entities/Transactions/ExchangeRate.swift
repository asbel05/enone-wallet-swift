//
//  ExchangeRate.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

struct ExchangeRate: Codable {
    let id: Int?
    let baseCurrency: String
    let targetCurrency: String
    let rate: Double
    let source: ExchangeRateSource
    let fetchedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case baseCurrency = "base_currency"
        case targetCurrency = "target_currency"
        case rate
        case source
        case fetchedAt = "fetched_at"
    }
    
    func convert(amount: Double) -> Double {
        return amount * rate
    }
}

enum ExchangeRateSource: String, Codable {
    case api = "API"
    case database = "DATABASE"
}

struct ExchangeRateAPIResponse: Decodable {
    let result: String
    let baseCode: String
    let conversionRates: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case result
        case baseCode = "base_code"
        case conversionRates = "conversion_rates"
    }
}
