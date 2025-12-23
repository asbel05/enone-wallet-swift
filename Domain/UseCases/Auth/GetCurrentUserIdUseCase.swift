//
//  GetCurrentUserIdUseCase.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

final class GetCurrentUserIdUseCase {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol = AuthRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute() async -> String? {
        return await repository.currentUserId()
    }
}
