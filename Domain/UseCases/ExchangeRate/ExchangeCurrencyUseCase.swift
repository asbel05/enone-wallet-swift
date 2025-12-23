//
//  ExchangeCurrencyUseCase.swift
//  enone
//
//  Created by Asbel on 19/12/25.
//

import Foundation

struct ExchangeCurrencyUseCase {
    private let transactionRepository: TransactionRepositoryProtocol
    private let exchangeRateRepository: ExchangeRateRepositoryProtocol
    
    init(
        transactionRepository: TransactionRepositoryProtocol = TransactionRepositoryImpl(),
        exchangeRateRepository: ExchangeRateRepositoryProtocol = ExchangeRateRepositoryImpl()
    ) {
        self.transactionRepository = transactionRepository
        self.exchangeRateRepository = exchangeRateRepository
    }
    
    func execute(
        amount: Double,
        fromWallet: Wallet,
        toWallet: Wallet
    ) async throws {
        guard fromWallet.balance >= amount else {
            throw ExchangeError.insufficientFunds
        }
        
        let rate = try await exchangeRateRepository.getRate(
            from: fromWallet.currency,
            to: toWallet.currency
        )
        
        let amountToReceive = rate.convert(amount: amount)
        
        let newFromBalance = fromWallet.balance - amount
        let newToBalance = toWallet.balance + amountToReceive
        
        print("💱 Ejecutando conversión:")
        print("   Desde: \(fromWallet.currency) - Balance: \(fromWallet.balance) → \(newFromBalance)")
        print("   Hacia: \(toWallet.currency) - Balance: \(toWallet.balance) → \(newToBalance)")
        print("   Tasa: \(rate.rate)")
        print("   Monto: \(amount) → \(amountToReceive)")
        
        try await transactionRepository.executeConversion(
            fromWalletId: fromWallet.id,
            toWalletId: toWallet.id,
            amount: amount,
            amountToReceive: amountToReceive,
            fromCurrency: fromWallet.currency,
            toCurrency: toWallet.currency,
            rate: rate.rate,
            newFromBalance: newFromBalance,
            newToBalance: newToBalance
        )
        
        print("Conversión completada")
    }
}

enum ExchangeError: LocalizedError {
    case insufficientFunds
    case sameCurrency
    case invalidAmount
    
    var errorDescription: String? {
        switch self {
        case .insufficientFunds:
            return "Fondos insuficientes para realizar la conversión"
        case .sameCurrency:
            return "No puedes convertir a la misma moneda"
        case .invalidAmount:
            return "El monto debe ser mayor a 0"
        }
    }
}
