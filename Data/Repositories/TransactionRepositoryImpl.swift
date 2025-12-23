//
//  TransactionRepository.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation
import Supabase
import Realtime

final class TransactionRepositoryImpl: TransactionRepositoryProtocol {
    
    private let dataSource: TransactionDataSource
    private let exchangeRateDataSource: ExchangeRateDataSource
    private let client = SupabaseClientProvider.shared.client
    
    init(
        dataSource: TransactionDataSource = TransactionDataSource(),
        exchangeRateDataSource: ExchangeRateDataSource = ExchangeRateDataSource()
    ) {
        self.dataSource = dataSource
        self.exchangeRateDataSource = exchangeRateDataSource
    }

    func subscribeToTransactions(userId: UUID) -> AsyncStream<[Transaction]> {
        return AsyncStream { continuation in
            let channel = client.channel("public:transactions:\(userId)")
            
            let changes = channel.postgresChange(
                InsertAction.self,
                table: "transactions",
                filter: .eq("related_user_id", value: userId.uuidString)
            )
            
            Task {
                for await change in changes {
                    do {
                        let data = try JSONEncoder().encode(change.record)
                        let newTransaction = try JSONDecoder().decode(Transaction.self, from: data)
                        continuation.yield([newTransaction])
                    } catch {
                        print("Error decoding transaction realtime: \(error)")
                    }
                }
            }
            
            Task {
                await channel.subscribe()
            }
        }
    }

    func executeTransfer(
        fromWalletId: Int,
        toWalletNumber: String,
        amount: Double,
        currency: String,
        description: String?
    ) async throws -> TransferResult {
        guard let toWallet = try await dataSource.findWallet(byNumber: toWalletNumber) else {
            throw TransferError.walletNotFound
        }
        
        let fromWallet = try await getWalletById(fromWalletId)
        
        return try await dataSource.executeTransfer(
            fromWalletId: fromWalletId,
            toWalletId: toWallet.id,
            toUserId: toWallet.userId,
            toWalletNumber: toWallet.walletNumber,
            fromWalletNumber: fromWallet.walletNumber,
            fromUserId: fromWallet.userId,
            amount: amount,
            currency: currency,
            description: description
        )
    }
    
    func validateTransfer(
        userId: String,
        fromWalletId: Int,
        toWalletNumber: String,
        amount: Double,
        currency: String
    ) async throws -> TransferValidation {
        
        try await dataSource.resetDailyVolumeIfNeeded(userId: userId)
        
        let fromWallet = try await getWalletById(fromWalletId)
        
        if fromWallet.walletNumber == toWalletNumber {
            return TransferValidation(
                isValid: false,
                destinationWalletId: nil,
                destinationUserId: nil,
                destinationUserName: nil,
                currentBalance: fromWallet.balance,
                dailyVolumeUsed: 0,
                dailyLimit: 0,
                remainingLimit: 0,
                requires2FA: false,
                errorMessage: TransferError.sameWalletTransfer.localizedDescription
            )
        }

        guard let toWallet = try await dataSource.findWallet(byNumber: toWalletNumber) else {
            return TransferValidation(
                isValid: false,
                destinationWalletId: nil,
                destinationUserId: nil,
                destinationUserName: nil,
                currentBalance: fromWallet.balance,
                dailyVolumeUsed: 0,
                dailyLimit: 0,
                remainingLimit: 0,
                requires2FA: false,
                errorMessage: TransferError.walletNotFound.localizedDescription
            )
        }
        
        if fromWallet.currency != toWallet.currency {
            return TransferValidation(
                isValid: false,
                destinationWalletId: toWallet.id,
                destinationUserId: toWallet.userId,
                destinationUserName: nil,
                currentBalance: fromWallet.balance,
                dailyVolumeUsed: 0,
                dailyLimit: 0,
                remainingLimit: 0,
                requires2FA: false,
                errorMessage: TransferError.currencyMismatch.localizedDescription
            )
        }
        
        if fromWallet.balance < amount {
            return TransferValidation(
                isValid: false,
                destinationWalletId: toWallet.id,
                destinationUserId: toWallet.userId,
                destinationUserName: nil,
                currentBalance: fromWallet.balance,
                dailyVolumeUsed: 0,
                dailyLimit: 0,
                remainingLimit: 0,
                requires2FA: false,
                errorMessage: TransferError.insufficientBalance.localizedDescription
            )
        }
        
        let limitsInfo = try await dataSource.getUserLimitsInfo(userId: userId)
        
        let exchangeRate = try await exchangeRateDataSource.getRate(from: "USD", to: "PEN")
        let usdToPenRate = exchangeRate.rate
        
        let volumeUsedInPEN = limitsInfo.totalVolumeInPEN(usdToPenRate: usdToPenRate)
        let remainingInPEN = limitsInfo.remainingLimitInPEN(usdToPenRate: usdToPenRate)
        
        let amountInPEN = limitsInfo.amountInPEN(amount, currency: currency, usdToPenRate: usdToPenRate)
        
        if amountInPEN > remainingInPEN {
            return TransferValidation(
                isValid: false,
                destinationWalletId: toWallet.id,
                destinationUserId: toWallet.userId,
                destinationUserName: nil,
                currentBalance: fromWallet.balance,
                dailyVolumeUsed: volumeUsedInPEN,
                dailyLimit: limitsInfo.dailyLimit,
                remainingLimit: remainingInPEN,
                requires2FA: limitsInfo.twoFactorEnabled,
                errorMessage: TransferError.dailyLimitExceeded.localizedDescription
            )
        }
        
        let destName = try await dataSource.getUserName(userId: toWallet.userId)

        return TransferValidation(
            isValid: true,
            destinationWalletId: toWallet.id,
            destinationUserId: toWallet.userId,
            destinationUserName: destName,
            currentBalance: fromWallet.balance,
            dailyVolumeUsed: volumeUsedInPEN,
            dailyLimit: limitsInfo.dailyLimit,
            remainingLimit: remainingInPEN,
            requires2FA: limitsInfo.twoFactorEnabled,
            errorMessage: nil
        )
    }

    func getTransactionHistory(
        walletId: Int,
        limit: Int,
        offset: Int
    ) async throws -> [Transaction] {
        return try await dataSource.getTransactionHistory(
            walletId: walletId,
            limit: limit,
            offset: offset
        )
    }
    
    func getTransaction(id: Int) async throws -> Transaction {
        return try await dataSource.getTransaction(id: id)
    }
    
    func getTransactionBySecurityCode(code: String) async throws -> Transaction {
        throw TransferError.transactionFailed
    }

    func checkAndResetDailyVolume(userId: String) async throws {
        try await dataSource.resetDailyVolumeIfNeeded(userId: userId)
    }
    
    func updateDailyVolume(userId: String, amount: Double, currency: String) async throws {
        try await dataSource.updateDailyVolume(userId: userId, amount: amount, currency: currency)
    }

    private func getWalletById(_ walletId: Int) async throws -> WalletInfo {
        struct WalletRecord: Decodable {
            let id: Int
            let user_id: String
            let wallet_number: String
            let currency: String
            let balance: Double
        }
        
        let response: [WalletRecord] = try await SupabaseClientProvider.shared.client
            .from("wallets")
            .select()
            .eq("id", value: walletId)
            .execute()
            .value
        
        guard let wallet = response.first else {
            throw TransferError.walletNotFound
        }
        
        return WalletInfo(
            id: wallet.id,
            userId: wallet.user_id,
            walletNumber: wallet.wallet_number,
            currency: wallet.currency,
            balance: wallet.balance
        )
    }

    func findWalletByUserEmail(email: String, currency: String) async throws -> WalletSearchResult? {
        return try await dataSource.findWalletByUserEmail(email: email, currency: currency)
    }

    func executeConversion(
        fromWalletId: Int,
        toWalletId: Int,
        amount: Double,
        amountToReceive: Double,
        fromCurrency: String,
        toCurrency: String,
        rate: Double,
        newFromBalance: Double,
        newToBalance: Double
    ) async throws {
        try await dataSource.executeConversion(
            fromWalletId: fromWalletId,
            toWalletId: toWalletId,
            amount: amount,
            amountToReceive: amountToReceive,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            rate: rate,
            newFromBalance: newFromBalance,
            newToBalance: newToBalance
        )
    }
}
