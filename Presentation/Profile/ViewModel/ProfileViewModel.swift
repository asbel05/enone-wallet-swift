//
//  ProfileViewModel.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import Foundation

final class ProfileViewModel {
    
    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onProfileLoaded: ((Profile) -> Void)?
    var onTwoFactorChanged: ((Bool) -> Void)?
    
    private let getCurrentUserIdUseCase: GetCurrentUserIdUseCase
    private let getUserProfileUseCase: GetUserProfileUseCase
    
    private(set) var profile: Profile?
    
    init(
        getCurrentUserIdUseCase: GetCurrentUserIdUseCase = GetCurrentUserIdUseCase(),
        getUserProfileUseCase: GetUserProfileUseCase = GetUserProfileUseCase()
    ) {
        self.getCurrentUserIdUseCase = getCurrentUserIdUseCase
        self.getUserProfileUseCase = getUserProfileUseCase
    }
    
    func loadProfile() {
        if let cached = CacheManager.shared.profile.get() {
            let cachedProfile = Profile(
                id: cached.userId,
                email: cached.email,
                emailVerified: true,
                onboardingCompleted: true,
                phone: cached.phone,
                dni: cached.dni,
                firstName: nil,
                firstLastName: nil,
                secondLastName: nil,
                fullName: cached.fullName,
                gender: cached.gender,
                transactionLimit: nil,
                lastLimitChange: nil,
                dailyVolume: nil,
                dailyVolumeUSD: nil,
                twoFactorEnabled: false,
                twoFactorSecret: nil,
                createdAt: nil,
                updatedAt: nil
            )
            self.profile = cachedProfile
            onProfileLoaded?(cachedProfile)
        }
        
        onLoadingChange?(true)
        
        Task {
            do {
                guard let userId = await getCurrentUserIdUseCase.execute() else {
                    await MainActor.run {
                        onLoadingChange?(false)
                        onError?("No se pudo identificar al usuario")
                    }
                    return
                }
                
                let profile = try await getUserProfileUseCase.execute(userId: userId)
                
                await MainActor.run {
                    self.profile = profile
                    
                    let cached = ProfileCache.CachedProfile(
                        userId: profile.id,
                        fullName: profile.fullName,
                        email: profile.email,
                        phone: profile.phone,
                        dni: profile.dni,
                        gender: profile.gender
                    )
                    CacheManager.shared.profile.save(cached)
                    
                    onLoadingChange?(false)
                    onProfileLoaded?(profile)
                }
                
            } catch {
                await MainActor.run {
                    onLoadingChange?(false)
                    onError?("Error al cargar el perfil: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getFormattedGender() -> String {
        guard let gender = profile?.gender else { return "No especificado" }
        
        switch gender {
        case "M": return "Masculino"
        case "F": return "Femenino"
        default: return "No especificado"
        }
    }
}
