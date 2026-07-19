//
//  Typography.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//

import SwiftUI

extension Font {
    // MARK: - Headings
    static let headingLarge = Font.system(size: 34, weight: .bold)
    static let headingMedium = Font.system(size: 28, weight: .semibold)
    static let headingSmall = Font.system(size: 22, weight: .semibold)
    
    // MARK: - Body Text
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)
    
    // MARK: - Labels
    static let labelLarge = Font.system(size: 17, weight: .semibold)
    static let labelMedium = Font.system(size: 15, weight: .medium)
    static let labelSmall = Font.system(size: 13, weight: .medium)
    
    // MARK: - Captions
    static let customCaption = Font.system(size: 12, weight: .regular)
    static let customCaptionEmphasized = Font.system(size: 12, weight: .semibold)
}
