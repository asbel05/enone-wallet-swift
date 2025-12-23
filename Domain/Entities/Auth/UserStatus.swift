//
//  UserStatus.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

enum UserStatus {
    case notAuthenticated
    case emailNotVerified(email: String)
    case profileIncomplete
    case fullyVerified
}
