//
//  TransactionsViewModel.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

final class TransactionsViewModel {

    private let transferFundsUseCase: TransferFundsUseCase
    private let validateTransferUseCase: ValidateTransferUseCase
    private let getHistoryUseCase: GetTransactionHistoryUseCase
    private let findWalletByEmailUseCase: FindWalletByEmailUseCase

    var currentUserId: String?
    var currentWalletId: Int?
    var currentWalletNumber: String?
    var currentCurrency: String = "PEN"
    var currentBalance: Double = 0
    
    var balancePEN: Double = 0
    var balanceUSD: Double = 0
    var walletIdPEN: Int?
    var walletIdUSD: Int?
    
    var transactions: [Transaction] = []
    var currentPage: Int = 0
    var hasMorePages: Bool = true
    
    var pendingTransferRequest: TransferRequest?
    var pendingValidation: TransferValidation?
    var destinationEmail: String?
    var destinationUserName: String?

    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onTransactionsLoaded: (([Transaction]) -> Void)?
    var onTransferValidated: ((TransferValidation) -> Void)?
    var onTransferCompleted: ((TransferResult) -> Void)?
    var on2FARequired: (() -> Void)?

    init(
        transferFundsUseCase: TransferFundsUseCase = TransferFundsUseCase(),
        validateTransferUseCase: ValidateTransferUseCase = ValidateTransferUseCase(),
        getHistoryUseCase: GetTransactionHistoryUseCase = GetTransactionHistoryUseCase(),
        findWalletByEmailUseCase: FindWalletByEmailUseCase = FindWalletByEmailUseCase()
    ) {
        self.transferFundsUseCase = transferFundsUseCase
        self.validateTransferUseCase = validateTransferUseCase
        self.getHistoryUseCase = getHistoryUseCase
        self.findWalletByEmailUseCase = findWalletByEmailUseCase
    }

    func loadTransactions(refresh: Bool = false) {
        guard let walletId = currentWalletId else {
            onError?("No se encontró tu billetera")
            return
        }
        
        if refresh {
            currentPage = 0
            transactions = []
            hasMorePages = true
        }
        
        guard hasMorePages else { return }
        
        onLoadingChange?(true)
        
        Task { @MainActor in
            do {
                let newTransactions = try await getHistoryUseCase.execute(
                    walletId: walletId,
                    page: currentPage
                )
                
                transactions.append(contentsOf: newTransactions)
                hasMorePages = newTransactions.count == 20
                currentPage += 1
                
                onTransactionsLoaded?(transactions)
            } catch {
                onError?(error.localizedDescription)
            }
            onLoadingChange?(false)
        }
    }

    func validateTransferByEmail(
        destinationEmail: String,
        amount: Double,
        currency: String,
        description: String?
    ) {
        guard let userId = currentUserId else {
            onError?("Debes iniciar sesión")
            return
        }
        
        onLoadingChange?(true)
        
        Task { @MainActor in
            do {
                guard let searchResult = try await findWalletByEmailUseCase.execute(
                    email: destinationEmail,
                    currency: currency
                ) else {
                    onError?("No se encontró un usuario con ese email o no tiene wallet de \(currency == "PEN" ? "Soles" : "Dólares")")
                    onLoadingChange?(false)
                    return
                }
                
                if searchResult.walletInfo.userId == userId {
                    onError?("No puedes enviarte dinero a ti mismo")
                    onLoadingChange?(false)
                    return
                }
                
                self.destinationEmail = destinationEmail
                self.destinationUserName = searchResult.userName
                
                let request = TransferRequest(
                    destinationWalletNumber: searchResult.walletInfo.walletNumber,
                    amount: amount,
                    currency: currency,
                    description: description
                )
                
                let fromWalletId = currency == "PEN" ? (walletIdPEN ?? currentWalletId!) : (walletIdUSD ?? currentWalletId!)
                
                let validation = try await validateTransferUseCase.execute(
                    userId: userId,
                    fromWalletId: fromWalletId,
                    request: request
                )
                
                pendingTransferRequest = request
                pendingValidation = validation
                
                currentWalletId = fromWalletId
                
                if validation.isValid {
                    onTransferValidated?(validation)
                } else {
                    onError?(validation.errorMessage ?? "Error de validación")
                }
            } catch {
                onError?(error.localizedDescription)
            }
            onLoadingChange?(false)
        }
    }

    func executeTransfer(verificationCode: String? = nil) {
        guard let userId = currentUserId,
              let walletId = currentWalletId,
              let request = pendingTransferRequest,
              let validation = pendingValidation else {
            onError?("No hay transferencia pendiente")
            return
        }
        
        if validation.requires2FA && verificationCode == nil {
            request2FACode()
            return
        }
        
        onLoadingChange?(true)
        
        Task { @MainActor in
            do {
                let result = try await transferFundsUseCase.execute(
                    userId: userId,
                    fromWalletId: walletId,
                    request: request,
                    verificationCode: verificationCode
                )
                
                pendingTransferRequest = nil
                pendingValidation = nil
                
                currentBalance = result.newBalance
                if currentCurrency == "PEN" {
                    balancePEN = result.newBalance
                } else {
                    balanceUSD = result.newBalance
                }
                
                onTransferCompleted?(result)
            } catch TransferError.twoFactorRequired {
                request2FACode()
            } catch {
                onError?(error.localizedDescription)
            }
            onLoadingChange?(false)
        }
    }

    private func request2FACode() {
        on2FARequired?()
    }
}
