//
//  SpacingTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 6/13/26.
//

import Testing
import Foundation
import CoreGraphics
@testable import OnLife

@Suite("Spacing Tests")
struct SpacingTests {
    
    // MARK: - Spacing Value Tests
    
    @Test("Extra small spacing has correct value")
    func extraSmallSpacing() {
        let expected: CGFloat = 4
        #expect(Spacing.extraSmall == expected)
    }
    
    @Test("Small spacing has correct value")
    func smallSpacing() {
        let expected: CGFloat = 8
        #expect(Spacing.small == expected)
    }
    
    @Test("Medium spacing has correct value")
    func mediumSpacing() {
        let expected: CGFloat = 16
        #expect(Spacing.medium == expected)
    }
    
    @Test("Large spacing has correct value")
    func largeSpacing() {
        let expected: CGFloat = 24
        #expect(Spacing.large == expected)
    }
    
    @Test("Extra large spacing has correct value")
    func extraLargeSpacing() {
        let expected: CGFloat = 32
        #expect(Spacing.extraLarge == expected)
    }
    
    @Test("XX large spacing has correct value")
    func xxLargeSpacing() {
        let expected: CGFloat = 48
        #expect(Spacing.xxLarge == expected)
    }
    
    // MARK: - Spacing Relationship Tests
    
    @Test("Spacing values are in ascending order")
    func spacingValuesAscending() {
        #expect(Spacing.extraSmall < Spacing.small)
        #expect(Spacing.small < Spacing.medium)
        #expect(Spacing.medium < Spacing.large)
        #expect(Spacing.large < Spacing.extraLarge)
        #expect(Spacing.extraLarge < Spacing.xxLarge)
    }
    
    @Test("Spacing values follow consistent scaling")
    func spacingValuesScaling() {
        let multiplier2: CGFloat = 2
        let multiplier15: CGFloat = 1.5
        
        // Each level should be a reasonable multiple
        #expect(Spacing.small == Spacing.extraSmall * multiplier2)
        #expect(Spacing.medium == Spacing.small * multiplier2)
        #expect(Spacing.large == Spacing.medium * multiplier15)
        #expect(Spacing.xxLarge == Spacing.extraLarge * multiplier15)
    }
    
    // MARK: - Spacing Consistency Tests
    
    @Test("All spacing values are positive")
    func allSpacingValuesPositive() {
        let zero: CGFloat = 0
        #expect(Spacing.extraSmall > zero)
        #expect(Spacing.small > zero)
        #expect(Spacing.medium > zero)
        #expect(Spacing.large > zero)
        #expect(Spacing.extraLarge > zero)
        #expect(Spacing.xxLarge > zero)
    }
    
    @Test("All spacing values are whole numbers")
    func allSpacingValuesWholeNumbers() {
        let divisor: CGFloat = 1
        let zero: CGFloat = 0
        
        #expect(Spacing.extraSmall.truncatingRemainder(dividingBy: divisor) == zero)
        #expect(Spacing.small.truncatingRemainder(dividingBy: divisor) == zero)
        #expect(Spacing.medium.truncatingRemainder(dividingBy: divisor) == zero)
        #expect(Spacing.large.truncatingRemainder(dividingBy: divisor) == zero)
        #expect(Spacing.extraLarge.truncatingRemainder(dividingBy: divisor) == zero)
        #expect(Spacing.xxLarge.truncatingRemainder(dividingBy: divisor) == zero)
    }
    
    // MARK: - Design System Tests
    
    @Test("Spacing follows 8-point grid system")
    func spacingFollowsEightPointGrid() {
        let gridUnit: CGFloat = 4
        let zero: CGFloat = 0
        
        // All spacing values should be divisible by 4 (half of 8pt grid)
        #expect(Spacing.extraSmall.truncatingRemainder(dividingBy: gridUnit) == zero)
        #expect(Spacing.small.truncatingRemainder(dividingBy: gridUnit) == zero)
        #expect(Spacing.medium.truncatingRemainder(dividingBy: gridUnit) == zero)
        #expect(Spacing.large.truncatingRemainder(dividingBy: gridUnit) == zero)
        #expect(Spacing.extraLarge.truncatingRemainder(dividingBy: gridUnit) == zero)
        #expect(Spacing.xxLarge.truncatingRemainder(dividingBy: gridUnit) == zero)
    }
}
