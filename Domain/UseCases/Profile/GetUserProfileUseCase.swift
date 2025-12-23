//
//  GetUserProfileUseCase.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import Foundation

final class GetUserProfileUseCase {
    private let repository: ProfileRepositoryProtocol
    
    init(repository: ProfileRepositoryProtocol = ProfileRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute(userId: String) async throws -> Profile {
        return try await repository.getUserProfile(userId: userId)
    }
}
