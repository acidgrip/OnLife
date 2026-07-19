//
//  OnLifeApp.swift
//  OnLife
//
//  Created by Daniel Lee on 7/18/26.
//

import SwiftUI
import SwiftData

@main
struct OnLifeApp: App {
    @State private var authState = AuthenticationState()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if authState.isAuthenticated {
                HomeView()
                    .environment(authState)
            } else {
                LoginView()
                    .environment(authState)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
