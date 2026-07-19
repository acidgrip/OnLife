//
//  ColorsTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/13/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("Colors Tests")
struct ColorsTests {
    
    // MARK: - Primary Colors Tests
    
    @Test("Theme primary color is defined")
    func themePrimaryColorDefined() {
        let color = Color.themePrimary
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    @Test("Theme secondary color is defined")
    func themeSecondaryColorDefined() {
        let color = Color.themeSecondary
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    @Test("Theme accent color is defined")
    func themeAccentColorDefined() {
        let color = Color.themeAccent
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    // MARK: - Background Colors Tests
    
    @Test("Background primary color is defined")
    func backgroundPrimaryColorDefined() {
        let color = Color.backgroundPrimary
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    @Test("Background secondary color is defined")
    func backgroundSecondaryColorDefined() {
        let color = Color.backgroundSecondary
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    @Test("Background tertiary color is defined")
    func backgroundTertiaryColorDefined() {
        let color = Color.backgroundTertiary
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    // MARK: - Text Colors Tests
    
    @Test("Text primary color is defined")
    func textPrimaryColorDefined() {
        let color = Color.textPrimary
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    @Test("Text secondary color is defined")
    func textSecondaryColorDefined() {
        let color = Color.textSecondary
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    // MARK: - Status Colors Tests
    
    @Test("Success color is defined")
    func successColorDefined() {
        let color = Color.success
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    @Test("Warning color is defined")
    func warningColorDefined() {
        let color = Color.warning
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    @Test("Error color is defined")
    func errorColorDefined() {
        let color = Color.error
        
        // Verify color exists by checking description
        #expect(String(describing: color).isEmpty == false)
    }
    
    // MARK: - Color Consistency Tests
    
    @Test("All theme colors are defined")
    func allThemeColorsDefined() {
        // Verify all theme colors exist
        #expect(String(describing: Color.themePrimary).isEmpty == false)
        #expect(String(describing: Color.themeSecondary).isEmpty == false)
        #expect(String(describing: Color.themeAccent).isEmpty == false)
    }
    
    @Test("All status colors are defined")
    func allStatusColorsDefined() {
        // Verify all status colors exist
        #expect(String(describing: Color.success).isEmpty == false)
        #expect(String(describing: Color.warning).isEmpty == false)
        #expect(String(describing: Color.error).isEmpty == false)
    }
    
    // MARK: - Design System Tests
    
    @Test("All background colors are defined")
    func allBackgroundColorsDefined() {
        // Verify all background colors exist
        #expect(String(describing: Color.backgroundPrimary).isEmpty == false)
        #expect(String(describing: Color.backgroundSecondary).isEmpty == false)
        #expect(String(describing: Color.backgroundTertiary).isEmpty == false)
    }
    
    @Test("All text colors are defined")
    func allTextColorsDefined() {
        // Verify all text colors exist
        #expect(String(describing: Color.textPrimary).isEmpty == false)
        #expect(String(describing: Color.textSecondary).isEmpty == false)
    }
}
