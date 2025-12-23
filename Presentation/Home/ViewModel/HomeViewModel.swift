//
//  HomeViewModel.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

@MainActor
final class HomeViewModel {
    
    private let getWalletsUseCase: GetWalletsUseCase
    private let subscribeToWalletsUseCase: SubscribeToWalletsUseCase
    private let getExchangeRateUseCase: GetExchangeRateUseCase
    private let cacheManager: CacheManager
    
    var onStateChanged: (() -> Void)?
    var onCurrencyChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private(set) var wallets: [Wallet] = [] {
        didSet {
            onStateChanged?()
        }
    }
    
    private(set) var isLoading: Bool = false {
        didSet {
            onStateChanged?()
        }
    }

    private(set) var selectedCurrency: String = "PEN" {
        didSet {
            onCurrencyChanged?()
        }
    }
    
    var isShowingPEN: Bool {
        return selectedCurrency == "PEN"
    }
    
    var currentWallet: Wallet? {
        return wallets.first { $0.currency == selectedCurrency }
    }

    var mainWallet: Wallet? {
        return wallets.first { $0.currency == "PEN" } ?? wallets.first
    }
    
    private(set) var currentExchangeRate: ExchangeRate? {
        didSet {
            onStateChanged?()
        }
    }

    init(
        getWalletsUseCase: GetWalletsUseCase = GetWalletsUseCase(),
        subscribeToWalletsUseCase: SubscribeToWalletsUseCase = SubscribeToWalletsUseCase(),
        getExchangeRateUseCase: GetExchangeRateUseCase = GetExchangeRateUseCase(),
        cacheManager: CacheManager = .shared
    ) {
        self.getWalletsUseCase = getWalletsUseCase
        self.subscribeToWalletsUseCase = subscribeToWalletsUseCase
        self.getExchangeRateUseCase = getExchangeRateUseCase
        self.cacheManager = cacheManager
        
        self.selectedCurrency = cacheManager.preferences.selectedCurrency
    }

    func loadData() {
        Task {
            isLoading = true
            do {
                guard let userIdString = await SessionManager.shared.currentUserId(),
                      let userId = UUID(uuidString: userIdString) else {
                    isLoading = false
                    onError?("No session found")
                    return
                }
                
                let fetchedWallets = try await getWalletsUseCase.execute(userId: userId)
                self.wallets = fetchedWallets
                
                let rate = try? await getExchangeRateUseCase.execute(from: "USD", to: "PEN")
                self.currentExchangeRate = rate
                
                isLoading = false
                
                startListening(userId: userId)
                
            } catch {
                print("Error fetching wallets: \(error)")
                self.wallets = []
                isLoading = false
            }
        }
    }
    
    private func startListening(userId: UUID) {
        Task {
            for await updatedWallets in subscribeToWalletsUseCase.execute(userId: userId) {
                self.wallets = updatedWallets
            }
        }
    }

    func toggleCurrency() {
        selectedCurrency = isShowingPEN ? "USD" : "PEN"
        cacheManager.preferences.selectedCurrency = selectedCurrency
    }
    
    func getSelectedCurrency() -> String {
        return cacheManager.preferences.selectedCurrency
    }
}
