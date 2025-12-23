//
//  Theme.swift
//  enone
//
//  Created by Assistant on 18/12/25.
//

import UIKit

struct Theme {
    
    struct Colors {
        static let primary = UIColor(red: 0.20, green: 0.52, blue: 0.70, alpha: 1.0)
        static let primaryDark = UIColor(red: 0.15, green: 0.47, blue: 0.65, alpha: 1.0)
        
        static let usdGreen = UIColor(red: 0.20, green: 0.60, blue: 0.46, alpha: 1.0)
        
        static let background = UIColor.white
        static let surface = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        
        static let textPrimary = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        static let textSecondary = UIColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.0)
        static let textOnPrimary = UIColor.white
        
        static let error = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1.0)
        static let success = UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1.0)
        
        static let divider = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
    }
    
    struct Fonts {
        static let largeTitle = UIFont.systemFont(ofSize: 32, weight: .bold)
        static let title = UIFont.systemFont(ofSize: 24, weight: .bold)
        static let subtitle = UIFont.systemFont(ofSize: 18, weight: .medium)
        static let headline = UIFont.systemFont(ofSize: 18, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let bodyMedium = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let button = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let caption = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let small = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    struct Layout {
        static let cornerRadius: CGFloat = 12.0
        static let padding: CGFloat = 24.0
        static let inputHeight: CGFloat = 56.0
        static let buttonHeight: CGFloat = 52.0
        static let spacing: CGFloat = 16.0
    }
}
