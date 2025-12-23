import Foundation

protocol TransactionRepositoryProtocol {
    
    func executeTransfer(
        fromWalletId: Int,
        toWalletNumber: String,
        amount: Double,
        currency: String,
        description: String?
    ) async throws -> TransferResult
    
    func validateTransfer(
        userId: String,
        fromWalletId: Int,
        toWalletNumber: String,
        amount: Double,
        currency: String
    ) async throws -> TransferValidation
    
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
    ) async throws
    
    func getTransactionHistory(
        walletId: Int,
        limit: Int,
        offset: Int
    ) async throws -> [Transaction]
    
    func getTransaction(id: Int) async throws -> Transaction
    
    func getTransactionBySecurityCode(code: String) async throws -> Transaction
    
    func subscribeToTransactions(userId: UUID) -> AsyncStream<[Transaction]>
    
    func checkAndResetDailyVolume(userId: String) async throws
    
    func updateDailyVolume(userId: String, amount: Double, currency: String) async throws
    
    func findWalletByUserEmail(email: String, currency: String) async throws -> WalletSearchResult?
}

struct TransferValidation {
    let isValid: Bool
    let destinationWalletId: Int?
    let destinationUserId: String?
    let destinationUserName: String?
    let currentBalance: Double
    let dailyVolumeUsed: Double
    let dailyLimit: Double
    let remainingLimit: Double
    let requires2FA: Bool
    let errorMessage: String?
}
