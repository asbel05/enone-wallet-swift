//
//  AuthRepositoryProtocol.swift
//  enone
//
//  Created by Asbel on 16/12/25.
//

import Foundation

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws
    
    func register(email: String, password: String) async throws
    
    func logout() async throws
    
    func isLoggedIn() async -> Bool
    
    func currentUserId() async -> String?
    
    func currentEmail() async -> String?
    
    func verifyEmailOTP(email: String, token: String) async throws
    
    func resendOTP(email: String) async throws
}
