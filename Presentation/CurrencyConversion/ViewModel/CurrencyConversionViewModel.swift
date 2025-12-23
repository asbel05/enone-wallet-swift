//
//  CurrencyConversionViewModel.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//  Refactorizado: 23/12/25 - Simplificado, el cache lo maneja el DataSource
//

import Foundation

@MainActor
final class CurrencyConversionViewModel {
    
    private let getExchangeRateUseCase: GetExchangeRateUseCase
    private let exchangeCurrencyUseCase: ExchangeCurrencyUseCase
    private let getWalletsUseCase: GetWalletsUseCase
    
    var onStateChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    
    private(set) var wallets: [Wallet] = [] {
        didSet { onStateChanged?() }
    }
    
    private(set) var usdToPenRate: ExchangeRate? {
        didSet { onStateChanged?() }
    }
    
    private(set) var penToUsdRate: ExchangeRate? {
        didSet { onStateChanged?() }
    }
    
    private(set) var isLoading: Bool = false {
        didSet { onStateChanged?() }
    }
    
    var calculatorAmount: Double = 100.0 {
        didSet { onStateChanged?() }
    }
    
    var isUsdToPen: Bool = false {
        didSet { onStateChanged?() }
    }
    
    var calculatedResult: Double {
        if isUsdToPen {
            return calculatorAmount * (usdToPenRate?.rate ?? 1.0)
        } else {
            return calculatorAmount * (penToUsdRate?.rate ?? 1.0)
        }
    }
    
    var fromWallet: Wallet? {
        wallets.first { $0.currency == (isUsdToPen ? "USD" : "PEN") }
    }
    
    var toWallet: Wallet? {
        wallets.first { $0.currency == (isUsdToPen ? "PEN" : "USD") }
    }
    
    var hasInsufficientFunds: Bool {
        guard let from = fromWallet else { return true }
        return from.balance < calculatorAmount
    }
    
    var cacheRemainingMinutes: Int {
        ExchangeRateCache.shared.remainingMinutes()
    }
    
    var lastUpdateTime: Date? {
        ExchangeRateCache.shared.getTimestamp()
    }

    init(
        getExchangeRateUseCase: GetExchangeRateUseCase = GetExchangeRateUseCase(),
        exchangeCurrencyUseCase: ExchangeCurrencyUseCase = ExchangeCurrencyUseCase(),
        getWalletsUseCase: GetWalletsUseCase = GetWalletsUseCase()
    ) {
        self.getExchangeRateUseCase = getExchangeRateUseCase
        self.exchangeCurrencyUseCase = exchangeCurrencyUseCase
        self.getWalletsUseCase = getWalletsUseCase
    }

    func loadData() {
        Task {
            isLoading = true
            do {
                guard let userIdString = await SessionManager.shared.currentUserId(),
                      let userId = UUID(uuidString: userIdString) else {
                    throw ExchangeError.invalidAmount
                }
                
                async let walletsTask = getWalletsUseCase.execute(userId: userId)
                async let usdRateTask = getExchangeRateUseCase.execute(from: "USD", to: "PEN")
                async let penRateTask = getExchangeRateUseCase.execute(from: "PEN", to: "USD")
                
                self.wallets = try await walletsTask
                self.usdToPenRate = try await usdRateTask
                self.penToUsdRate = try await penRateTask
                
                isLoading = false
            } catch {
                isLoading = false
                onError?("Error al cargar datos: \(error.localizedDescription)")
            }
        }
    }

    func refreshRates() {
        Task {
            isLoading = true
            do {
                try await getExchangeRateUseCase.refreshRates()
                
                async let usdRateTask = getExchangeRateUseCase.execute(from: "USD", to: "PEN")
                async let penRateTask = getExchangeRateUseCase.execute(from: "PEN", to: "USD")
                
                self.usdToPenRate = try await usdRateTask
                self.penToUsdRate = try await penRateTask
                
                isLoading = false
                onSuccess?("Tipos de cambio actualizados")
            } catch {
                isLoading = false
                onError?("Error al actualizar: \(error.localizedDescription)")
            }
        }
    }

    func toggleCurrency() {
        isUsdToPen.toggle()
    }
    
    func updateAmount(_ amount: Double) {
        calculatorAmount = max(0, amount)
    }

    func executeExchange() {
        guard let from = fromWallet, let to = toWallet else {
            onError?("No se encontraron las wallets")
            return
        }
        
        guard calculatorAmount > 0 else {
            onError?("El monto debe ser mayor a 0")
            return
        }
        
        guard calculatorAmount >= 1.0 else {
            onError?("El monto mínimo es 1.00")
            return
        }
        
        guard !hasInsufficientFunds else {
            let symbol = from.currency == "PEN" ? "S/" : "$"
            onError?("Fondos insuficientes. Saldo disponible: \(symbol) \(String(format: "%.2f", from.balance))")
            return
        }
        
        Task {
            isLoading = true
            do {
                let resultAmount = calculatedResult
                
                try await exchangeCurrencyUseCase.execute(
                    amount: calculatorAmount,
                    fromWallet: from,
                    toWallet: to
                )
                
                if let userIdString = await SessionManager.shared.currentUserId(),
                   let userId = UUID(uuidString: userIdString) {
                    self.wallets = try await getWalletsUseCase.execute(userId: userId)
                }
                
                isLoading = false
                
                let fromSymbol = from.currency == "PEN" ? "S/" : "$"
                let toSymbol = to.currency == "PEN" ? "S/" : "$"
                onSuccess?("Conversión exitosa: \(fromSymbol) \(String(format: "%.2f", calculatorAmount)) → \(toSymbol) \(String(format: "%.2f", resultAmount))")
            } catch {
                isLoading = false
                onError?("Error al ejecutar conversión: \(error.localizedDescription)")
            }
        }
    }
}
