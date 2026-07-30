//
//  StringEmailTests.swift
//  OnlifeTests
//
//  Created by Daniel Lee on 7/30/26.
//

import Testing
import Foundation
@testable import OnLife

@Suite("String+Email normalizedEmail Tests")
struct StringEmailTests {

    @Test("Already-lowercase email is unchanged")
    func alreadyLowercase() {
        #expect("jane@example.com".normalizedEmail == "jane@example.com")
    }

    @Test("Uppercase local part is lowercased")
    func uppercaseLocalPart() {
        #expect("Jane@example.com".normalizedEmail == "jane@example.com")
    }

    @Test("Uppercase domain is lowercased")
    func uppercaseDomain() {
        #expect("jane@EXAMPLE.COM".normalizedEmail == "jane@example.com")
    }

    @Test("Fully uppercase email is lowercased")
    func fullyUppercase() {
        #expect("JANE@EXAMPLE.COM".normalizedEmail == "jane@example.com")
    }

    @Test("Mixed-case email is lowercased")
    func mixedCase() {
        #expect("JaNe.DoE@ExAmPlE.CoM".normalizedEmail == "jane.doe@example.com")
    }

    @Test("Leading and trailing whitespace is trimmed")
    func trimsWhitespace() {
        #expect("  jane@example.com  ".normalizedEmail == "jane@example.com")
    }

    @Test("Mixed case with surrounding whitespace is both trimmed and lowercased")
    func trimsAndLowercases() {
        #expect("  Jane@Example.com\n".normalizedEmail == "jane@example.com")
    }

    @Test("Empty string stays empty")
    func emptyString() {
        #expect("".normalizedEmail == "")
    }

    @Test("Whitespace-only string becomes empty")
    func whitespaceOnly() {
        #expect("   ".normalizedEmail == "")
    }

    @Test("Different-case variants of the same address normalize to the same value")
    func caseVariantsConverge() {
        let variants = ["jane@example.com", "Jane@Example.com", "JANE@EXAMPLE.COM", "jAnE@eXaMpLe.CoM"]
        let normalized = Set(variants.map { $0.normalizedEmail })

        #expect(normalized.count == 1, "All case variants of the same email should normalize to a single value")
    }
}
