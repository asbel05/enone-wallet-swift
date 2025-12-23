//
//  TransactionDataSource.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation
import Supabase

final class TransactionDataSource {
    
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseClientProvider.shared.client) {
        self.client = client
    }

    func executeTransfer(
        fromWalletId: Int,
        toWalletId: Int,
        toUserId: String,
        toWalletNumber: String,
        fromWalletNumber: String,
        fromUserId: String,
        amount: Double,
        currency: String,
        description: String?
    ) async throws -> TransferResult {

        let securityCode = generateSecurityCode()
        
        let fromBalance = try await getWalletBalance(walletId: fromWalletId)
        let toBalance = try await getWalletBalance(walletId: toWalletId)
        
        let newFromBalance = fromBalance - amount
        let newToBalance = toBalance + amount
        
        let desc = description ?? "Transferencia"
        
        struct InsertTransaction: Encodable {
            let wallet_id: Int
            let amount: Double
            let currency: String
            let type: String
            let status: String
            let description: String
            let related_user_id: String
            let related_wallet_number: String
            let security_code: String
            let balance_after: Double
        }
        
        let outTransaction = InsertTransaction(
            wallet_id: fromWalletId,
            amount: -amount,
            currency: currency,
            type: "TRANSFER_OUT",
            status: "COMPLETED",
            description: desc,
            related_user_id: toUserId,
            related_wallet_number: toWalletNumber,
            security_code: securityCode,
            balance_after: newFromBalance
        )
        
        let inTransaction = InsertTransaction(
            wallet_id: toWalletId,
            amount: amount,
            currency: currency,
            type: "TRANSFER_IN",
            status: "COMPLETED",
            description: desc,
            related_user_id: fromUserId,
            related_wallet_number: fromWalletNumber,
            security_code: securityCode,
            balance_after: newToBalance
        )
        
        struct InsertedTransaction: Decodable {
            let id: Int
        }
        
        let outResult: [InsertedTransaction] = try await client
            .from("transactions")
            .insert(outTransaction)
            .select("id")
            .execute()
            .value
        
        let _ = try await client
            .from("transactions")
            .insert(inTransaction)
            .execute()

        try await updateWalletBalance(walletId: fromWalletId, newBalance: newFromBalance)
        
        try await updateWalletBalance(walletId: toWalletId, newBalance: newToBalance)
        
        let destName = try await getUserName(userId: toUserId)
        
        guard let transactionId = outResult.first?.id else {
            throw TransferError.transactionFailed
        }
                
        return TransferResult(
            transactionId: transactionId,
            securityCode: securityCode,
            amount: amount,
            currency: currency,
            destinationWalletNumber: toWalletNumber,
            destinationUserName: destName,
            newBalance: newFromBalance,
            timestamp: Date(),
            description: description
        )
    }
    
    func findWallet(byNumber walletNumber: String) async throws -> WalletInfo? {
        struct WalletRecord: Decodable {
            let id: Int
            let user_id: String
            let wallet_number: String
            let currency: String
            let balance: Double
            let status: String
        }
        
        let response: [WalletRecord] = try await client
            .from("wallets")
            .select()
            .eq("wallet_number", value: walletNumber)
            .eq("status", value: "ACTIVE")
            .execute()
            .value
        
        guard let wallet = response.first else {
            return nil
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
        struct UserRecord: Decodable {
            let id: String
            let email: String?
            let first_name: String?
            let first_last_name: String?
        }
        
        let emailClean = email.lowercased().trimmingCharacters(in: .whitespaces)
        
        let users: [UserRecord] = try await client
            .from("profiles")
            .select("id, email, first_name, first_last_name")
            .eq("email", value: emailClean)
            .execute()
            .value
        
        guard let user = users.first else {
            print("Usuario no encontrado con email: \(emailClean)")
            return nil
        }
                
        struct WalletRecord: Decodable {
            let id: Int
            let user_id: String
            let wallet_number: String
            let currency: String
            let balance: Double
            let status: String?
        }
                
        let allUserWallets: [WalletRecord] = try await client
            .from("wallets")
            .select()
            .eq("user_id", value: user.id)
            .execute()
            .value
        
        for w in allUserWallets {
            print("   - ID: \(w.id), Currency: \(w.currency), Status: \(w.status ?? "nil")")
        }
        
        let wallets: [WalletRecord] = try await client
            .from("wallets")
            .select()
            .eq("user_id", value: user.id)
            .eq("currency", value: currency)
            .eq("status", value: "ACTIVE")
            .execute()
            .value
                
        guard let wallet = wallets.first else {
            print("Wallet \(currency) no encontrada para usuario \(user.id)")
            return nil
        }
                
        let userName = "\(user.first_name ?? "") \(user.first_last_name ?? "")".trimmingCharacters(in: .whitespaces)
        
        return WalletSearchResult(
            walletInfo: WalletInfo(
                id: wallet.id,
                userId: wallet.user_id,
                walletNumber: wallet.wallet_number,
                currency: wallet.currency,
                balance: wallet.balance
            ),
            userEmail: user.email ?? email,
            userName: userName.isEmpty ? "Usuario EnOne" : userName
        )
    }
    
    func getUserName(userId: String) async throws -> String {
        struct ProfileRecord: Decodable {
            let first_name: String?
            let first_last_name: String?
        }
        
        let response: [ProfileRecord] = try await client
            .from("profiles")
            .select("first_name, first_last_name")
            .eq("id", value: userId)
            .execute()
            .value
        
        guard let profile = response.first else {
            return "Usuario"
        }
        
        let firstName = profile.first_name ?? ""
        let lastName = profile.first_last_name ?? ""
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    func getUserLimitsInfo(userId: String) async throws -> UserLimitsInfo {
        struct LimitsRecord: Decodable {
            let transaction_limit: Double?
            let daily_volume_pen: Double?
            let daily_volume_usd: Double?
            let last_volume_reset_at: String?
            let two_factor_enabled: Bool?
        }
        
        let response: [LimitsRecord] = try await client
            .from("profiles")
            .select("transaction_limit, daily_volume_pen, daily_volume_usd, last_volume_reset_at, two_factor_enabled")
            .eq("id", value: userId)
            .execute()
            .value
        
        guard let record = response.first else {
            throw TransferError.userNotAuthenticated
        }
        
        return UserLimitsInfo(
            dailyLimit: record.transaction_limit ?? 500,
            volumePEN: record.daily_volume_pen ?? 0,
            volumeUSD: record.daily_volume_usd ?? 0,
            lastResetAt: record.last_volume_reset_at,
            twoFactorEnabled: record.two_factor_enabled ?? false
        )
    }

    func resetDailyVolumeIfNeeded(userId: String) async throws {
        let info = try await getUserLimitsInfo(userId: userId)
        
        var peruCalendar = Calendar(identifier: .gregorian)
        peruCalendar.timeZone = TimeZone(identifier: "America/Lima") ?? TimeZone(secondsFromGMT: -5 * 3600)!
        
        let todayPeru = peruCalendar.startOfDay(for: Date())
        
        var shouldReset = false
        
        if let lastResetString = info.lastResetAt {
            let formatter = ISO8601DateFormatter()
            if let lastResetDate = formatter.date(from: lastResetString) {
                let lastResetDayPeru = peruCalendar.startOfDay(for: lastResetDate)
                shouldReset = lastResetDayPeru < todayPeru
            }
        } else {
            shouldReset = true
        }
        
        if shouldReset {
            struct ResetData: Encodable {
                let daily_volume_pen: Double
                let daily_volume_usd: Double
                let last_volume_reset_at: String
            }
            
            let resetData = ResetData(
                daily_volume_pen: 0,
                daily_volume_usd: 0,
                last_volume_reset_at: ISO8601DateFormatter().string(from: Date())
            )
            
            try await client
                .from("profiles")
                .update(resetData)
                .eq("id", value: userId)
                .execute()
        }
    }

    func updateDailyVolume(userId: String, amount: Double, currency: String) async throws {
        let info = try await getUserLimitsInfo(userId: userId)
        
        if currency == "PEN" {
            let newVolume = info.volumePEN + amount
            try await client
                .from("profiles")
                .update(["daily_volume_pen": newVolume])
                .eq("id", value: userId)
                .execute()
        } else if currency == "USD" {
            let newVolume = info.volumeUSD + amount
            try await client
                .from("profiles")
                .update(["daily_volume_usd": newVolume])
                .eq("id", value: userId)
                .execute()
        }
    }

    func getTransactionHistory(walletId: Int, limit: Int, offset: Int) async throws -> [Transaction] {
        let response: [Transaction] = try await client
            .from("transactions")
            .select()
            .eq("wallet_id", value: walletId)
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
        
        return response
    }
    
    func getTransaction(id: Int) async throws -> Transaction {
        let response: [Transaction] = try await client
            .from("transactions")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        
        guard let transaction = response.first else {
            throw TransferError.transactionFailed
        }
        
        return transaction
    }

    private func getWalletBalance(walletId: Int) async throws -> Double {
        struct BalanceRecord: Decodable {
            let balance: Double
        }
        
        let response: [BalanceRecord] = try await client
            .from("wallets")
            .select("balance")
            .eq("id", value: walletId)
            .execute()
            .value
        
        return response.first?.balance ?? 0
    }
    
    private func updateWalletBalance(walletId: Int, newBalance: Double) async throws {
        struct UpdateBalance: Encodable {
            let balance: Double
            let updated_at: String
        }
        
        let data = UpdateBalance(
            balance: newBalance,
            updated_at: ISO8601DateFormatter().string(from: Date())
        )
        
        try await client
            .from("wallets")
            .update(data)
            .eq("id", value: walletId)
            .execute()
    }
    
    private func generateSecurityCode() -> String {
        return String(format: "%04d", Int.random(in: 0...9999))
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
        
        print("🔄 INICIANDO CONVERSIÓN")
        
        struct TransactionResult: Decodable {
            let id: Int
        }
        
        struct ConvertData: Encodable {
            let wallet_id: Int
            let amount: Double
            let currency: String
            let type: String
            let status: String
            let description: String
            let security_code: String
            let balance_after: Double
        }
        
        struct UpdateBalance: Encodable {
            let balance: Double
        }
        
        let outData = ConvertData(
            wallet_id: fromWalletId,
            amount: -amount,
            currency: fromCurrency,
            type: "CONVERT_OUT",
            status: "COMPLETED",
            description: "CONV",
            security_code: String(format: "%04d", Int.random(in: 0...9999)),
            balance_after: newFromBalance
        )
        
        let _: [TransactionResult] = try await self.client
            .from("transactions")
            .insert(outData)
            .select()
            .execute()
            .value
        
        let inData = ConvertData(
            wallet_id: toWalletId,
            amount: amountToReceive,
            currency: toCurrency,
            type: "CONVERT_IN",
            status: "COMPLETED",
            description: "CONV",
            security_code: String(format: "%04d", Int.random(in: 0...9999)),
            balance_after: newToBalance
        )
        
        let _: [TransactionResult] = try await self.client
            .from("transactions")
            .insert(inData)
            .select()
            .execute()
            .value
        
        try await self.client
            .from("wallets")
            .update(UpdateBalance(balance: newFromBalance))
            .eq("id", value: fromWalletId)
            .execute()
        
        try await self.client
            .from("wallets")
            .update(UpdateBalance(balance: newToBalance))
            .eq("id", value: toWalletId)
            .execute()
    }
}

struct WalletInfo {
    let id: Int
    let userId: String
    let walletNumber: String
    let currency: String
    let balance: Double
}

struct UserLimitsInfo {
    let dailyLimit: Double
    let volumePEN: Double
    let volumeUSD: Double
    let lastResetAt: String?
    let twoFactorEnabled: Bool

    func totalVolumeInPEN(usdToPenRate: Double) -> Double {
        return volumePEN + (volumeUSD * usdToPenRate)
    }

    func remainingLimitInPEN(usdToPenRate: Double) -> Double {
        let totalUsed = totalVolumeInPEN(usdToPenRate: usdToPenRate)
        return max(0, dailyLimit - totalUsed)
    }
    
    func amountInPEN(_ amount: Double, currency: String, usdToPenRate: Double) -> Double {
        if currency == "USD" {
            return amount * usdToPenRate
        }
        return amount
    }
    
    func remainingLimit(for currency: String) -> Double {
        let used = currency == "PEN" ? volumePEN : volumeUSD
        return max(0, dailyLimit - used)
    }
}

struct WalletSearchResult {
    let walletInfo: WalletInfo
    let userEmail: String
    let userName: String
}
