import Foundation

protocol WalletRepositoryProtocol {
    func getWallets(userId: UUID) async throws -> [Wallet]
    func getBalance(userId: String, currency: String) async throws -> Double
    func subscribeToWallets(userId: UUID) -> AsyncStream<[Wallet]>
}
