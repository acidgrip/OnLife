//
//  LocationPermissionView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

struct LocationPermissionView: View {
    @State private var store = LocationPermissionStore()
    @Environment(\.dismiss) private var dismiss
    
    let onComplete: () -> Void
    
    // MARK: - Gradient Definitions
    
    private var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.4, blue: 0.3)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                navigationBar
                
                VStack(spacing: Spacing.extraLarge) {
                    Spacer()
                    
                    // Illustration
                    illustrationSection
                    
                    // Title and Description
                    headerSection
                    
                    Spacer()
                    
                    // Privacy Notice
                    privacyNotice
                    
                    // Allow Location Button
                    allowLocationButton
                    
                    // Privacy Notice
                    exactLocationNotice
                    
                    // Not Now Button
                    notNowButton
                    
                    // Limited Experience Notice
                    limitedExperienceNotice
                    
                    Spacer()
                        .frame(height: Spacing.medium)
                }
                .padding(.horizontal, Spacing.large)
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .onChange(of: store.authorizationStatus) { oldValue, newValue in
            if store.isAuthorized {
                // Location permission granted, complete onboarding
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
    
    // MARK: - Navigation Bar
    
    private var navigationBar: some View {
        HStack(spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(primaryGradient)
            }
            
            Spacer()
            
            Text("ONLIFE")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(primaryGradient)
                .tracking(2)
            
            Spacer()
            
            // Invisible button to balance layout
            Image(systemName: "arrow.left")
                .font(.title2)
                .fontWeight(.medium)
                .opacity(0)
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, Spacing.medium)
        .padding(.bottom, Spacing.small)
    }
    
    // MARK: - Illustration Section
    
    private var illustrationSection: some View {
        ZStack {
            // Background card
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.25, blue: 0.3),
                            Color(red: 0.1, green: 0.15, blue: 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 280)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // People avatars arranged in a grid-like pattern
            peopleAvatarsGrid
        }
        .padding(.vertical, Spacing.medium)
    }
    
    private var peopleAvatarsGrid: some View {
        // Simplified representation of the people grid
        // In a real app, you'd use actual avatar images or SF Symbols
        VStack(spacing: 16) {
            // Row 1
            HStack(spacing: 20) {
                avatarCircle(color: .gray.opacity(0.6))
                avatarCircle(color: .gray.opacity(0.7))
                avatarCircle(color: .gray.opacity(0.6))
            }
            
            // Row 2
            HStack(spacing: 20) {
                avatarCircle(color: .gray.opacity(0.5))
                avatarCircle(color: Color(red: 1.0, green: 0.7, blue: 0.5))
                avatarCircle(color: .gray.opacity(0.7))
            }
            
            // Row 3
            HStack(spacing: 20) {
                avatarCircle(color: .gray.opacity(0.6))
                avatarCircle(color: .gray.opacity(0.5))
                avatarCircle(color: .gray.opacity(0.6))
            }
            
            // Row 4
            HStack(spacing: 20) {
                avatarCircle(color: .white.opacity(0.8))
                avatarCircle(color: .gray.opacity(0.6))
                avatarCircle(color: Color(red: 1.0, green: 0.7, blue: 0.5))
                avatarCircle(color: .gray.opacity(0.5))
            }
        }
        .padding(Spacing.large)
    }
    
    private func avatarCircle(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 44, height: 44)
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
            )
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: Spacing.medium) {
            Text("See people and\nscenes around you")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.8)
            
            Text("Find connections and discover what's\nhappening nearby.")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.9)
        }
    }
    
    // MARK: - Privacy Notice
    
    private var privacyNotice: some View {
        EmptyView()
    }
    
    // MARK: - Allow Location Button
    
    private var allowLocationButton: some View {
        Button {
            store.requestPermission()
        } label: {
            HStack {
                if store.isLoading {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text("Allow Location")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(primaryGradient)
            .foregroundColor(.black)
            .cornerRadius(28)
        }
        .disabled(store.isLoading || !store.canRequestPermission)
        .opacity(store.canRequestPermission ? 1.0 : 0.6)
    }
    
    // MARK: - Exact Location Notice
    
    private var exactLocationNotice: some View {
        Text("Your exact location is never shared with\nother users.")
            .font(.subheadline)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
    }
    
    // MARK: - Not Now Button
    
    private var notNowButton: some View {
        Button {
            onComplete()
        } label: {
            Text("Not Now")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .underline()
        }
        .padding(.top, Spacing.small)
    }
    
    // MARK: - Limited Experience Notice
    
    private var limitedExperienceNotice: some View {
        Text("Limited experience without location")
            .font(.caption)
            .foregroundColor(.gray.opacity(0.7))
            .padding(.top, Spacing.extraSmall)
    }
}

// MARK: - Preview

#Preview {
    LocationPermissionView {
        print("Location permission complete")
    }
}
