//
//  CardOperationResponse.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

struct CardOperationResponse: Codable {
    let success: Bool
    let error: String?
    let cardId: Int?
    let maskedNumber: String?
    let transactionId: Int?
    let newBalance: Double?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case error
        case cardId = "card_id"
        case maskedNumber = "masked_number"
        case transactionId = "transaction_id"
        case newBalance = "new_balance"
        case message
    }
}
