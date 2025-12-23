import Foundation
import Supabase
import Realtime

final class WalletRepositoryImpl: WalletRepositoryProtocol {
    private let client = SupabaseClientProvider.shared.client
    
    func getWallets(userId: UUID) async throws -> [Wallet] {
        let response: [Wallet] = try await client
            .from("wallets")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return response
    }
    
    func getBalance(userId: String, currency: String) async throws -> Double {
        struct BalanceResult: Decodable {
            let balance: Double
        }
        
        let response: [BalanceResult] = try await client
            .from("wallets")
            .select("balance")
            .eq("user_id", value: userId)
            .eq("currency", value: currency)
            .limit(1)
            .execute()
            .value
        
        return response.first?.balance ?? 0.0
    }
    
    func subscribeToWallets(userId: UUID) -> AsyncStream<[Wallet]> {
        return AsyncStream { continuation in
            let channel = client.channel("public:wallets:\(userId)")
            
            let changes = channel.postgresChange(
                AnyAction.self,
                table: "wallets",
                filter: .eq("user_id", value: userId.uuidString)
            )
            
            Task {
                for await _ in changes {
                    do {
                        let wallets = try await self.getWallets(userId: userId)
                        print("Tiempo real: Wallets actualizados")
                        for wallet in wallets {
                            print("   - \(wallet.currency): \(wallet.balance)")
                        }
                        continuation.yield(wallets)
                    } catch {
                        print("Error realtime wallets: \(error)")
                    }
                }
            }
            
            Task {
                await channel.subscribe()
            }
        }
    }
}
