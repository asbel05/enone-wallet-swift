//
//  CacheProtocol.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import Foundation

protocol CacheStorage {
    func clear()
}

protocol ExpirableCacheStorage: CacheStorage {
    associatedtype T
    
    func get(maxAgeMinutes: Int) -> T?
    
    func isExpired(maxAgeMinutes: Int) -> Bool
}
