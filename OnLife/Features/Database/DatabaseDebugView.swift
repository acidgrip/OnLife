//
//  DatabaseDebugView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/29/26.
//
//  A debug view for testing database configurations
//  Add this to your app during development to easily switch between mock and Firebase
//

import SwiftUI

#if DEBUG
struct DatabaseDebugView: View {
    @State private var currentConfig: String = "Unknown"
    @State private var isSeeding = false
    @State private var showSeedSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    Section("Current Configuration") {
                        HStack {
                            Image(systemName: "server.rack")
                                .foregroundColor(.orange)
                            Text(currentConfig)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                    }
                    
                    Section("Switch Database") {
                        Button {
                            Task { @MainActor in
                                DatabaseManager.shared.configure(with: .firebase)
                                updateCurrentConfig()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("Use Firebase")
                                    .foregroundColor(.white)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                        
                        Button {
                            Task { @MainActor in
                                DatabaseManager.shared.configure(with: .mock(simulatedDelay: 0.3))
                                updateCurrentConfig()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "cube.fill")
                                    .foregroundColor(.blue)
                                Text("Use Mock Database")
                                    .foregroundColor(.white)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                    }
                    
                    Section("Seed Data") {
                        Button {
                            seedDatabase()
                        } label: {
                            HStack {
                                if isSeeding {
                                    ProgressView()
                                        .tint(.green)
                                } else {
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.green)
                                }
                                Text(isSeeding ? "Seeding..." : "Seed Sample Data")
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(isSeeding)
                        .listRowBackground(Color.gray.opacity(0.2))
                        
                        Text("Adds sample posts and events to your database")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .listRowBackground(Color.gray.opacity(0.2))
                    }
                    
                    Section("Authentication") {
                        if let userId = AuthService.shared.currentUserId {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("User ID")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(userId)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.gray.opacity(0.2))
                            
                            Button {
                                signOut()
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.red)
                                    Text("Sign Out")
                                        .foregroundColor(.white)
                                }
                            }
                            .listRowBackground(Color.gray.opacity(0.2))
                        } else {
                            Button {
                                signIn()
                            } label: {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.green)
                                    Text("Sign In Anonymously")
                                        .foregroundColor(.white)
                                }
                            }
                            .listRowBackground(Color.gray.opacity(0.2))
                        }
                    }
                    
                    Section("Info") {
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(title: "Realtime Updates", value: "\(FeatureFlags.realtimeFeed)")
                            InfoRow(title: "Nearby Events", value: "\(FeatureFlags.nearbyEvents)")
                            InfoRow(title: "Image Upload", value: "\(FeatureFlags.imageUpload)")
                            InfoRow(title: "Comments", value: "\(FeatureFlags.comments)")
                            InfoRow(title: "Push Notifications", value: "\(FeatureFlags.pushNotifications)")
                            InfoRow(title: "Analytics", value: "\(FeatureFlags.analytics)")
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Database Debug")
            .onAppear {
                updateCurrentConfig()
            }
            .alert("Success!", isPresented: $showSeedSuccess) {
                Button("OK") { }
            } message: {
                Text("Sample data has been added to your database")
            }
        }
    }
    
    private func updateCurrentConfig() {
        currentConfig = "\(DatabaseManager.shared.service)"
    }
    
    private func seedDatabase() {
        isSeeding = true
        Task {
            await FirebaseSeedData.seedDatabase()
            await MainActor.run {
                isSeeding = false
                showSeedSuccess = true
            }
        }
    }
    
    private func signIn() {
        Task {
            try? await AuthService.shared.signInAnonymously()
        }
    }
    
    private func signOut() {
        try? AuthService.shared.signOut()
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .font(.caption)
    }
}

#Preview {
    DatabaseDebugView()
}
#endif
