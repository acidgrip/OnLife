//
//  Colors.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension Color {
    // MARK: - Primary Colors
    static let themePrimary = Color.blue
    static let themeSecondary = Color.mint
    static let themeAccent = Color.purple
    
    // MARK: - Background Colors
    #if canImport(UIKit)
    static let backgroundPrimary = Color(uiColor: .systemBackground)
    static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
    static let backgroundTertiary = Color(uiColor: .tertiarySystemBackground)
    #else
    static let backgroundPrimary = Color(nsColor: .windowBackgroundColor)
    static let backgroundSecondary = Color(nsColor: .controlBackgroundColor)
    static let backgroundTertiary = Color(nsColor: .tertiarySystemFill)
    #endif
    
    // MARK: - Text Colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    // MARK: - Status Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
}
