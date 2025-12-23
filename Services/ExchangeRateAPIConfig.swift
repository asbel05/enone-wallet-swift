//
//  ExchangeRateAPIConfig.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

struct ExchangeRateAPIConfig {
    
    static let apiKey = "d2af27ba4bf0c6d20c67df5e"
    static let baseURL = "https://v6.exchangerate-api.com/v6"
    
    static var usdRatesURL: URL? {
        URL(string: "\(baseURL)/\(apiKey)/latest/USD")
    }
    
    static var penRatesURL: URL? {
        URL(string: "\(baseURL)/\(apiKey)/latest/PEN")
    }
    
    static func ratesURL(base: String) -> URL? {
        URL(string: "\(baseURL)/\(apiKey)/latest/\(base)")
    }
}
