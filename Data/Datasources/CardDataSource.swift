//
//  CardDataSource.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation
import Supabase

final class CardDataSource {
    
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseClientProvider.shared.client) {
        self.client = client
    }
    
    func getActiveCard(userId: String) async throws -> Card? {
        let response: [Card] = try await client
            .from("user_cards")
            .select()
            .eq("user_id", value: userId)
            .eq("is_active", value: true)
            .eq("is_verified", value: true)
            .limit(1)
            .execute()
            .value
        
        return response.first
    }
    
    func getAllCards(userId: String) async throws -> [Card] {
        let response: [Card] = try await client
            .from("user_cards")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    func activateCard(
        userId: String,
        cardNumber: String,
        cvv: String,
        expiryDate: String,
        holderName: String
    ) async throws -> CardOperationResponse {
        struct ActivateParams: Encodable {
            let p_user_id: String
            let p_numero: String
            let p_cvv: String
            let p_fecha_vencimiento: String
            let p_nombre_titular: String
        }
        
        let params = ActivateParams(
            p_user_id: userId,
            p_numero: cardNumber,
            p_cvv: cvv,
            p_fecha_vencimiento: expiryDate,
            p_nombre_titular: holderName
        )
        
        let response: CardOperationResponse = try await client
            .rpc("activate_user_card", params: params)
            .execute()
            .value
        
        return response
    }
    
    func deposit(userId: String, amount: Double, currency: String) async throws -> CardOperationResponse {
        struct DepositParams: Encodable {
            let p_user_id: String
            let p_amount: Double
            let p_currency: String
        }
        
        let params = DepositParams(
            p_user_id: userId,
            p_amount: amount,
            p_currency: currency
        )
        
        let response: CardOperationResponse = try await client
            .rpc("deposit_money", params: params)
            .execute()
            .value
        
        return response
    }
    
    func withdraw(userId: String, amount: Double, currency: String) async throws -> CardOperationResponse {
        struct WithdrawParams: Encodable {
            let p_user_id: String
            let p_amount: Double
            let p_currency: String
        }
        
        let params = WithdrawParams(
            p_user_id: userId,
            p_amount: amount,
            p_currency: currency
        )
        
        let response: CardOperationResponse = try await client
            .rpc("withdraw_money", params: params)
            .execute()
            .value
        
        return response
    }
}
