//
//  TypographyTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/13/26.
//

import Testing
import SwiftUI
@testable import OnLife

@Suite("Typography Tests")
struct TypographyTests {
    
    // MARK: - Heading Font Tests
    
    @Test("Heading large font is defined")
    func headingLargeFontDefined() {
        let font = Font.headingLarge
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    @Test("Heading medium font is defined")
    func headingMediumFontDefined() {
        let font = Font.headingMedium
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    @Test("Heading small font is defined")
    func headingSmallFontDefined() {
        let font = Font.headingSmall
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    // MARK: - Body Font Tests
    
    @Test("Body large font is defined")
    func bodyLargeFontDefined() {
        let font = Font.bodyLarge
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    @Test("Body medium font is defined")
    func bodyMediumFontDefined() {
        let font = Font.bodyMedium
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    @Test("Body small font is defined")
    func bodySmallFontDefined() {
        let font = Font.bodySmall
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    // MARK: - Label Font Tests
    
    @Test("Label large font is defined")
    func labelLargeFontDefined() {
        let font = Font.labelLarge
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    @Test("Label medium font is defined")
    func labelMediumFontDefined() {
        let font = Font.labelMedium
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    @Test("Label small font is defined")
    func labelSmallFontDefined() {
        let font = Font.labelSmall
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    // MARK: - Caption Font Tests
    
    @Test("Custom caption font is defined")
    func customCaptionFontDefined() {
        let font = Font.customCaption
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    @Test("Custom caption emphasized font is defined")
    func customCaptionEmphasizedFontDefined() {
        let font = Font.customCaptionEmphasized
        
        // Verify font exists by checking description
        #expect(String(describing: font).isEmpty == false)
    }
    
    // MARK: - Font Hierarchy Tests
    
    @Test("All heading fonts are defined")
    func allHeadingFontsDefined() {
        // Verify all heading fonts exist
        #expect(String(describing: Font.headingLarge).isEmpty == false)
        #expect(String(describing: Font.headingMedium).isEmpty == false)
        #expect(String(describing: Font.headingSmall).isEmpty == false)
    }
    
    @Test("All body fonts are defined")
    func allBodyFontsDefined() {
        // Verify all body fonts exist
        #expect(String(describing: Font.bodyLarge).isEmpty == false)
        #expect(String(describing: Font.bodyMedium).isEmpty == false)
        #expect(String(describing: Font.bodySmall).isEmpty == false)
    }
    
    @Test("All label fonts are defined")
    func allLabelFontsDefined() {
        // Verify all label fonts exist
        #expect(String(describing: Font.labelLarge).isEmpty == false)
        #expect(String(describing: Font.labelMedium).isEmpty == false)
        #expect(String(describing: Font.labelSmall).isEmpty == false)
    }
    
    // MARK: - Design System Tests
    
    @Test("All typography extensions are accessible")
    func allTypographyExtensionsAccessible() {
        // Verify all font extensions can be accessed
        let fonts = [
            Font.headingLarge,
            Font.headingMedium,
            Font.headingSmall,
            Font.bodyLarge,
            Font.bodyMedium,
            Font.bodySmall,
            Font.labelLarge,
            Font.labelMedium,
            Font.labelSmall
        ]
        
        for font in fonts {
            #expect(String(describing: font).isEmpty == false)
        }
    }
}
