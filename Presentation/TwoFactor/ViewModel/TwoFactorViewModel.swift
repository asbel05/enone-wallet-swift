//
//  TwoFactorViewModel.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import Foundation

final class TwoFactorViewModel {
    
    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    var onOTPRequested: (() -> Void)?
    var onStateChanged: ((Bool, String?) -> Void)?
    
    private let getCurrentUserIdUseCase: GetCurrentUserIdUseCase
    private let getUserProfileUseCase: GetUserProfileUseCase
    private let twoFactorUseCase: TwoFactorUseCase
    
    private(set) var isEnabled: Bool = false
    private(set) var currentSecret: String?
    
    init(
        getCurrentUserIdUseCase: GetCurrentUserIdUseCase = GetCurrentUserIdUseCase(),
        getUserProfileUseCase: GetUserProfileUseCase = GetUserProfileUseCase(),
        twoFactorUseCase: TwoFactorUseCase = TwoFactorUseCase()
    ) {
        self.getCurrentUserIdUseCase = getCurrentUserIdUseCase
        self.getUserProfileUseCase = getUserProfileUseCase
        self.twoFactorUseCase = twoFactorUseCase
    }
    
    func loadInitialState() {
        if let cached = CacheManager.shared.security.getTwoFactorState() {
            self.isEnabled = cached.enabled
            self.currentSecret = cached.secret
            self.onStateChanged?(cached.enabled, cached.secret)
        }
        
        onLoadingChange?(true)
        Task {
            guard let userId = await getCurrentUserIdUseCase.execute() else {
                await MainActor.run { self.onLoadingChange?(false) }
                return
            }
            do {
                let profile = try await getUserProfileUseCase.execute(userId: userId)
                await MainActor.run {
                    self.isEnabled = profile.twoFactorEnabled
                    if profile.twoFactorEnabled {
                        self.currentSecret = profile.twoFactorSecret
                    } else {
                        self.currentSecret = nil
                    }
                    
                    // Guardar en cache
                    CacheManager.shared.security.saveTwoFactorState(
                        enabled: self.isEnabled,
                        secret: self.currentSecret
                    )
                    
                    self.onStateChanged?(self.isEnabled, self.currentSecret)
                    self.onLoadingChange?(false)
                }
            } catch {
                await MainActor.run {
                    self.onError?(error.localizedDescription)
                    self.onLoadingChange?(false)
                }
            }
        }
    }
    
    func requestToggle() {
        onLoadingChange?(true)
        Task {
            guard let userId = await getCurrentUserIdUseCase.execute() else {
                await MainActor.run {
                    self.onLoadingChange?(false)
                    self.onError?("Usuario no identificado")
                }
                return
            }
            do {
                let profile = try await getUserProfileUseCase.execute(userId: userId)
                guard let email = profile.email else {
                    throw NSError(domain: "TwoFactor", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email no encontrado"])
                }
                
                _ = try await twoFactorUseCase.requestOTP(userId: userId, email: email)
                
                await MainActor.run {
                    self.onLoadingChange?(false)
                    self.onOTPRequested?()
                }
            } catch {
                await MainActor.run {
                    self.onError?(error.localizedDescription)
                    self.onLoadingChange?(false)
                }
            }
        }
    }
    
    func submitOTP(_ code: String) {
        guard code.isValid2FACode else {
            onError?("Ingresa un código de 6 dígitos")
            return
        }
        
        onLoadingChange?(true)
        Task {
            guard let userId = await getCurrentUserIdUseCase.execute() else {
                await MainActor.run {
                    self.onLoadingChange?(false)
                    self.onError?("Usuario no identificado")
                }
                return
            }
            do {
                let newState = try await twoFactorUseCase.verifyOTP(userId: userId, otp: code)
                
                let secret: String?
                if newState {
                    let profile = try await getUserProfileUseCase.execute(userId: userId)
                    secret = profile.twoFactorSecret
                } else {
                    secret = nil
                }
                
                let finalSecret = secret
                await MainActor.run {
                    self.isEnabled = newState
                    self.currentSecret = finalSecret
                    
                    CacheManager.shared.security.saveTwoFactorState(
                        enabled: newState,
                        secret: finalSecret
                    )
                    
                    self.onStateChanged?(newState, finalSecret)
                    self.onLoadingChange?(false)
                    self.onSuccess?(newState ? "2FA Activado" : "2FA Desactivado")
                }
            } catch {
                await MainActor.run {
                    self.onError?(error.localizedDescription)
                    self.onLoadingChange?(false)
                }
            }
        }
    }
}
