//
//  PreferencesCache.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import Foundation

final class PreferencesCache {
    
    static let shared = PreferencesCache()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let selectedCurrency = "pref_selected_currency"
        static let hasCompletedOnboarding = "pref_completed_onboarding"
        static let biometricEnabled = "pref_biometric_enabled"
        static let notificationsEnabled = "pref_notifications_enabled"
    }
    
    private init() {}
    
    private enum Defaults {
        static let currency = "PEN"
    }

    var selectedCurrency: String {
        get {
            return defaults.string(forKey: Keys.selectedCurrency) ?? Defaults.currency
        }
        set {
            defaults.set(newValue, forKey: Keys.selectedCurrency)
        }
    }
    
    func toggleCurrency() -> String {
        let current = selectedCurrency
        selectedCurrency = (current == "PEN") ? "USD" : "PEN"
        return selectedCurrency
    }

    var hasCompletedOnboarding: Bool {
        get {
            return defaults.bool(forKey: Keys.hasCompletedOnboarding)
        }
        set {
            defaults.set(newValue, forKey: Keys.hasCompletedOnboarding)
        }
    }

    var isBiometricEnabled: Bool {
        get {
            return defaults.bool(forKey: Keys.biometricEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.biometricEnabled)
        }
    }

    var areNotificationsEnabled: Bool {
        get {
            if defaults.object(forKey: Keys.notificationsEnabled) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.notificationsEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.notificationsEnabled)
        }
    }

    func resetToDefaults() {
        defaults.removeObject(forKey: Keys.selectedCurrency)
        defaults.removeObject(forKey: Keys.hasCompletedOnboarding)
        defaults.removeObject(forKey: Keys.biometricEnabled)
        defaults.removeObject(forKey: Keys.notificationsEnabled)
    }
}
