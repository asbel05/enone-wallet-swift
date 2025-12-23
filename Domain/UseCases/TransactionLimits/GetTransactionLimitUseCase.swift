//
//  GetTransactionLimitUseCase.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

final class GetTransactionLimitUseCase {
    private let profileRepository: ProfileRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol
    private let exchangeRateRepository: ExchangeRateRepositoryProtocol
    
    init(
        profileRepository: ProfileRepositoryProtocol,
        authRepository: AuthRepositoryProtocol,
        exchangeRateRepository: ExchangeRateRepositoryProtocol = ExchangeRateRepositoryImpl()
    ) {
        self.profileRepository = profileRepository
        self.authRepository = authRepository
        self.exchangeRateRepository = exchangeRateRepository
    }
    
    func execute() async throws -> TransactionLimitInfo {
        guard let userId = await authRepository.currentUserId() else {
            throw TransactionLimitError.userNotAuthenticated
        }
        
        let profile = try await profileRepository.getUserProfile(userId: userId)
        
        let limit = profile.transactionLimit ?? 500.0
        let lastChange = profile.lastLimitChange
        let volumePEN = profile.dailyVolume ?? 0.0
        let volumeUSD = profile.dailyVolumeUSD ?? 0.0
        
        let exchangeRate = try await exchangeRateRepository.getRate(from: "USD", to: "PEN")
        let usdToPenRate = exchangeRate.rate
        print("Tipo de cambio USD→PEN: \(usdToPenRate)")
        
        let usedToday = volumePEN + (volumeUSD * usdToPenRate)
        
        let canChange = canChangeLimitNow(lastChange: lastChange)
        
        return TransactionLimitInfo(
            currentLimit: limit,
            usedToday: usedToday,
            lastChangeDate: lastChange,
            canChange: canChange,
            minLimit: 500.0,
            maxLimit: 2000.0
        )
    }
    
    private func canChangeLimitNow(lastChange: String?) -> Bool {
        guard let lastChangeString = lastChange else {
            return true
        }
        
        let formatter = ISO8601DateFormatter()
        guard let lastChangeDate = formatter.date(from: lastChangeString) else {
            return true
        }
        
        let hoursSinceChange = Date().timeIntervalSince(lastChangeDate) / 3600
        return hoursSinceChange >= 24
    }
}

struct TransactionLimitInfo {
    let currentLimit: Double
    let usedToday: Double
    let lastChangeDate: String?
    let canChange: Bool
    let minLimit: Double
    let maxLimit: Double
    
    var limit: Double {
        return currentLimit
    }
    
    var formattedLimit: String {
        return "S/ \(String(format: "%.2f", currentLimit))"
    }
    
    var timeUntilCanChange: String? {
        guard !canChange, let lastChanges = lastChangeDate else { return nil }
        
        let formatter = ISO8601DateFormatter()
        guard let lastChange = formatter.date(from: lastChanges) else { return nil }
        
        let nextChangeDate = lastChange.addingTimeInterval(24 * 3600)
        let hoursRemaining = Int(nextChangeDate.timeIntervalSinceNow / 3600)
        
        if hoursRemaining > 0 {
            return "Podrás cambiar en \(hoursRemaining) horas"
        }
        return "Ya puedes cambiar tu límite"
    }
}

enum TransactionLimitError: LocalizedError {
    case userNotAuthenticated
    case invalidLimit
    case cannotChangeYet
    case invalidOTP
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "Usuario no autenticado"
        case .invalidLimit:
            return "El límite debe estar entre S/ 500 y S/ 2000"
        case .cannotChangeYet:
            return "Solo puedes cambiar el límite cada 24 horas"
        case .invalidOTP:
            return "Código de verificación inválido"
        }
    }
}
