//
//  Card.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

struct Card: Codable, Identifiable {
    let id: Int
    let userId: String
    let cardNumberMasked: String?
    let cardNumberHash: String?
    let holderName: String?
    let expiryMonth: Int?
    let expiryYear: Int?
    let cardBrand: String?
    let isActive: Bool
    let isVerified: Bool
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case cardNumberMasked = "card_number_masked"
        case cardNumberHash = "card_number_hash"
        case holderName = "holder_name"
        case expiryMonth = "expiry_month"
        case expiryYear = "expiry_year"
        case cardBrand = "card_brand"
        case isActive = "is_active"
        case isVerified = "is_verified"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension Card {
    var displayNumber: String {
        cardNumberMasked ?? "**** **** **** ****"
    }
    
    var expiryDate: String {
        guard let month = expiryMonth, let year = expiryYear else {
            return "--/--"
        }
        let shortYear = year % 100
        return String(format: "%02d/%02d", month, shortYear)
    }
    
    var brandIcon: String {
        switch cardBrand?.uppercased() {
        case "VISA": return "creditcard.fill"
        case "MASTERCARD": return "creditcard.fill"
        default: return "creditcard"
        }
    }
}
