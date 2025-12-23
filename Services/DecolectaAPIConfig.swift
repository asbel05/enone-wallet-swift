//
//  DecolectaAPIConfig.swift
//  enone
//
//  Created by Asbel on 14/12/25.
//

import Foundation

struct DecolectaAPIConfig {
    static let baseURL = "https://api.decolecta.com/v1"
    static let token = "sk_10748.eM4y0XVD5vZojkAezEVOs49vWRXbCHDa"

    static func dniEndpoint(dni: String) -> URL? {
        return URL(string: "\(baseURL)/reniec/dni?numero=\(dni)")
    }

    static var headers: [String: String] {
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
