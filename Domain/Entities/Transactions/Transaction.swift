//
//  Transaction.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

struct Transaction: Codable, Identifiable {
    let id: Int
    let walletId: Int
    let amount: Double
    let currency: String
    let type: TransactionType
    let status: TransactionStatus
    let description: String?
    let relatedUserId: String?
    let relatedWalletNumber: String?
    let securityCode: String
    let balanceAfter: Double
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case walletId = "wallet_id"
        case amount
        case currency
        case type
        case status
        case description
        case relatedUserId = "related_user_id"
        case relatedWalletNumber = "related_wallet_number"
        case securityCode = "security_code"
        case balanceAfter = "balance_after"
        case createdAt = "created_at"
    }
}

enum TransactionType: String, Codable {
    case transferOut = "TRANSFER_OUT"
    case transferIn = "TRANSFER_IN"
    case deposit = "DEPOSIT"
    case withdrawal = "WITHDRAWAL"
    case convertOut = "CONVERT_OUT"
    case convertIn = "CONVERT_IN"
    
    var displayName: String {
        switch self {
        case .transferOut: return "Enviado"
        case .transferIn: return "Recibido"
        case .deposit: return "Depósito"
        case .withdrawal: return "Retiro"
        case .convertOut: return "Conversión"
        case .convertIn: return "Conversión"
        }
    }
    
    var isIncoming: Bool {
        switch self {
        case .transferIn, .deposit, .convertIn:
            return true
        case .transferOut, .withdrawal, .convertOut:
            return false
        }
    }
}

enum TransactionStatus: String, Codable {
    case pending = "PENDING"
    case completed = "COMPLETED"
    case failed = "FAILED"
    case cancelled = "CANCELLED"
    
    var displayName: String {
        switch self {
        case .pending: return "Pendiente"
        case .completed: return "Completado"
        case .failed: return "Fallido"
        case .cancelled: return "Cancelado"
        }
    }
}

extension Transaction {
    
    var formattedAmount: String {
        let sign = type.isIncoming ? "+" : "-"
        return "\(sign) \(currency) \(String(format: "%.2f", abs(amount)))"
    }
    
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var date = formatter.date(from: createdAt)
        
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: createdAt)
        }
        
        guard let parsedDate = date else {
            return "Hoy"
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(parsedDate) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.locale = Locale(identifier: "es_PE")
            return "Hoy, \(timeFormatter.string(from: parsedDate))"
        }
        
        if calendar.isDateInYesterday(parsedDate) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            timeFormatter.locale = Locale(identifier: "es_PE")
            return "Ayer, \(timeFormatter.string(from: parsedDate))"
        }
        
        let days = calendar.dateComponents([.day], from: parsedDate, to: now).day ?? 0
        if days < 7 {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            dayFormatter.locale = Locale(identifier: "es_PE")
            return dayFormatter.string(from: parsedDate).capitalized
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "d MMM"
        displayFormatter.locale = Locale(identifier: "es_PE")
        return displayFormatter.string(from: parsedDate)
    }
    
    var shortDescription: String {
        if let desc = description, !desc.isEmpty {
            return desc
        }
        return type.displayName
    }
}
