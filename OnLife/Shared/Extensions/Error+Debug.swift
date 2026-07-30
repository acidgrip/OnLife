//
//  Error+Debug.swift
//  Onlife
//
//  Created by Daniel Lee on 7/30/26.
//

import Foundation

extension Error {
    /// Prints this error's full detail to the Xcode console, including any
    /// `NSError` `userInfo` and - critically - the underlying error Firebase
    /// often attaches under `NSUnderlyingErrorKey`.
    ///
    /// Firebase's SDKs frequently surface a generic top-level message (e.g.
    /// "An internal error has occurred, print and inspect the error details
    /// for more information") while the real cause (an invalid API key, a
    /// malformed backend response, a blocked region, etc.) is only present
    /// in that underlying error. `error.localizedDescription` alone - which
    /// is all the app's alerts show today - throws that detail away, so
    /// this is the "print and inspect" step Firebase's own message asks for.
    ///
    /// - Parameter context: A short label identifying where this error was
    ///   caught (e.g. "sendPhoneVerificationCode"), so multiple auth calls
    ///   logging around the same time are easy to tell apart in the console.
    func printDebugDetails(context: String) {
        let nsError = self as NSError
        print("🔴 [\(context)] \(nsError.domain) (\(nsError.code)): \(nsError.localizedDescription)")

        if !nsError.userInfo.isEmpty {
            print("🔴 [\(context)] userInfo: \(nsError.userInfo)")
        }

        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
            print("🔴 [\(context)] underlying error: \(underlying.domain) (\(underlying.code)): \(underlying)")
        }
    }
}
