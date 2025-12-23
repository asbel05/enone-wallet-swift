import Foundation

struct SubscribeToWalletsUseCase {
    private let repository: WalletRepositoryProtocol
    
    init(repository: WalletRepositoryProtocol = WalletRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute(userId: UUID) -> AsyncStream<[Wallet]> {
        return repository.subscribeToWallets(userId: userId)
    }
}
