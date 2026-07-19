//
//  ImageAssets.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//

import SwiftUI

// MARK: - Image Asset Names

enum ImageAsset {
    // Power Button States
    enum PowerButton {
        static let lightOff = "power button light off"
        static let lightOn = "power button light on"
        static let darkOff = "power button dark off"
        static let darkOn = "power button dark on"
    }
    
    // Logos
    enum Logo {
        static let dark = "onlife logo dark"
        static let light = "onlife logo light"
        static let iconDark = "onlife logo icon dark"
    }
}

// MARK: - Image Extensions

extension Image {
    /// Power button image that adapts to color scheme and online state
    static func powerButton(isOnline: Bool, colorScheme: ColorScheme) -> Image {
        let imageName: String
        switch (isOnline, colorScheme) {
        case (true, .light):
            imageName = ImageAsset.PowerButton.lightOn
        case (false, .light):
            imageName = ImageAsset.PowerButton.lightOff
        case (true, .dark):
            imageName = ImageAsset.PowerButton.darkOn
        case (false, .dark):
            imageName = ImageAsset.PowerButton.darkOff
        }
        return Image(imageName)
    }
    
    /// Onlife logo that adapts to color scheme
    static func onlifeLogo(colorScheme: ColorScheme) -> Image {
        let imageName = colorScheme == .dark ? ImageAsset.Logo.dark : ImageAsset.Logo.light
        return Image(imageName)
    }
    
    /// Onlife icon (currently only dark version available)
    static var onlifeIcon: Image {
        Image(ImageAsset.Logo.iconDark)
    }
}
