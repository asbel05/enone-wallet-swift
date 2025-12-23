//
//  Wallet.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

struct Wallet: Codable {
    let id: Int
    let userId: UUID
    let walletNumber: String
    let currency: String
    let balance: Double
    let status: String
    let createdAt: String
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case walletNumber = "wallet_number"
        case currency
        case balance
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
