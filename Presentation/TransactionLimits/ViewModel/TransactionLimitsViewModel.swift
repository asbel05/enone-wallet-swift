//
//  TransactionLimitsViewModel.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

final class TransactionLimitsViewModel {
    
    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onLimitInfoLoaded: ((TransactionLimitInfo) -> Void)?
    var onOTPGenerated: ((String) -> Void)?  // OTP generado
    var onLimitUpdated: (() -> Void)?
    
    private let getLimitUseCase: GetTransactionLimitUseCase
    private let updateLimitUseCase: UpdateTransactionLimitUseCase
    
    private(set) var currentLimitInfo: TransactionLimitInfo?
    private(set) var pendingNewLimit: Double?
    
    init(
        getLimitUseCase: GetTransactionLimitUseCase = GetTransactionLimitUseCase(
            profileRepository: ProfileRepositoryImpl(),
            authRepository: AuthRepositoryImpl()
        ),
        updateLimitUseCase: UpdateTransactionLimitUseCase = UpdateTransactionLimitUseCase(
            profileRepository: ProfileRepositoryImpl(),
            authRepository: AuthRepositoryImpl()
        )
    ) {
        self.getLimitUseCase = getLimitUseCase
        self.updateLimitUseCase = updateLimitUseCase
    }
    
    func loadLimitInfo() {
        onLoadingChange?(true)
        
        Task {
            do {
                let info = try await getLimitUseCase.execute()
                
                await MainActor.run {
                    self.currentLimitInfo = info
                    onLoadingChange?(false)
                    onLimitInfoLoaded?(info)
                }
            } catch {
                await MainActor.run {
                    onLoadingChange?(false)
                    onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func requestLimitChange(newLimit: Double) {
        guard let info = currentLimitInfo else { return }
        
        // Validaciones
        guard info.canChange else {
            onError?("Solo puedes cambiar el límite cada 24 horas")
            return
        }
        
        guard newLimit >= 500 && newLimit <= 2000 else {
            onError?("El límite debe estar entre S/ 500 y S/2000")
            return
        }
        
        guard newLimit != info.currentLimit else {
            onError?("El nuevo límite debe ser diferente al actual")
            return
        }
        
        onLoadingChange?(true)
        pendingNewLimit = newLimit
        
        Task {
            do {
                let otp = try await updateLimitUseCase.requestLimitChange(newLimit: newLimit)
                
                await MainActor.run {
                    onLoadingChange?(false)
                    onOTPGenerated?(otp)
                }
            } catch {
                await MainActor.run {
                    onLoadingChange?(false)
                    onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func verifyOTPAndUpdate(otp: String) {
        onLoadingChange?(true)
        
        Task {
            do {
                try await updateLimitUseCase.verifyAndUpdateLimit(otp: otp)
                
                await MainActor.run {
                    onLoadingChange?(false)
                    onLimitUpdated?()
                }
            } catch {
                await MainActor.run {
                    onLoadingChange?(false)
                    onError?("Código de verificación inválido")
                }
            }
        }
    }
}
