//
//  TransferRequest.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

/// Datos para solicitar una transferencia
struct TransferRequest {
    let destinationWalletNumber: String
    let amount: Double
    let currency: String
    let description: String?
    
    func validate() throws {
        guard !destinationWalletNumber.isEmpty else {
            throw TransferError.invalidWalletNumber
        }
        
        guard destinationWalletNumber.hasPrefix("EN") else {
            throw TransferError.invalidWalletNumber
        }
        
        guard amount > 0 else {
            throw TransferError.invalidAmount
        }
        
        guard amount >= 0.10 else {
            throw TransferError.amountTooLow(currency: currency)
        }
        
        guard currency == "PEN" || currency == "USD" else {
            throw TransferError.invalidCurrency
        }
    }
}

struct TransferResult {
    let transactionId: Int
    let securityCode: String
    let amount: Double
    let currency: String
    let destinationWalletNumber: String
    let destinationUserName: String
    let newBalance: Double
    let timestamp: Date
    let description: String?
}

enum TransferError: LocalizedError {
    case invalidWalletNumber
    case invalidAmount
    case amountTooLow(currency: String)
    case invalidCurrency
    case insufficientBalance
    case dailyLimitExceeded
    case walletNotFound
    case sameWalletTransfer
    case currencyMismatch
    case twoFactorRequired
    case twoFactorInvalid
    case userNotAuthenticated
    case transactionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidWalletNumber:
            return "Número de billetera inválido"
        case .invalidAmount:
            return "Monto inválido"
        case .amountTooLow(let currency):
            let symbol = currency == "USD" ? "$" : "S/"
            return "El monto mínimo es \(symbol) 0.10"
        case .invalidCurrency:
            return "Moneda no soportada"
        case .insufficientBalance:
            return "Saldo insuficiente"
        case .dailyLimitExceeded:
            return "Has excedido tu límite diario de transacciones"
        case .walletNotFound:
            return "La billetera destino no existe"
        case .sameWalletTransfer:
            return "No puedes transferirte a ti mismo"
        case .currencyMismatch:
            return "Solo puedes transferir a billeteras de la misma moneda"
        case .twoFactorRequired:
            return "Se requiere verificación de dos factores"
        case .twoFactorInvalid:
            return "Código de verificación inválido"
        case .userNotAuthenticated:
            return "Debes iniciar sesión"
        case .transactionFailed:
            return "Error al procesar la transacción"
        }
    }
}
