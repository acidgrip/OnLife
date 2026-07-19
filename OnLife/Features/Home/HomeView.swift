//
//  HomeView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//

import SwiftUI

struct HomeView: View {
    @State private var store = HomeStore()
    @State private var isOnline = true
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ActivityFeedView()
                .navigationTitle("")
                .toolbar {
                    #if os(macOS)
                    // macOS: Logo and button in toolbar
                    ToolbarItem(placement: .navigation) {
                        Image.onlifeLogo(colorScheme: colorScheme)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24)
                    }
                    
                    ToolbarItem(placement: .automatic) {
                        PowerButton(isOnline: $isOnline, size: 28)
                    }
                    #else
                    // iOS/iPadOS: Logo in center, button trailing
                    ToolbarItem(placement: .principal) {
                        Image.onlifeLogo(colorScheme: colorScheme)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 28)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        PowerButton(isOnline: $isOnline, size: 32)
                    }
                    #endif
                }
                #if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
        }
    }
}

#Preview {
    HomeView()
}
