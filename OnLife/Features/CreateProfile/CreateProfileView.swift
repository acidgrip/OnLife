//
//  CreateProfileView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

struct CreateProfileView: View {
    @State private var store = CreateProfileStore()
    @FocusState private var focusedField: Field?
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Field Enum
    
    enum Field {
        case username
        case name
        case bio
    }
    
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
                
                VStack(spacing: Spacing.medium) {
                    Spacer()
                        .frame(height: Spacing.small)
                    
                    // Title
                    headerSection
                    
                    Spacer()
                        .frame(height: Spacing.medium)
                    
                    // Form Fields
                    formSection
                    
                    Spacer()
                    
                    // Continue Button
                    continueButton
                    
                    Spacer()
                        .frame(height: Spacing.small)
                }
                .padding(.horizontal, Spacing.large)
                
                // Progress Indicator
                progressIndicator
                    .padding(.bottom, Spacing.large)
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .alert("Success", isPresented: $store.showSuccess) {
            Button("OK") {
                // TODO: Navigate to next onboarding step or main app
                dismiss()
            }
        } message: {
            Text("Profile created successfully!")
        }
        .alert("Error", isPresented: $store.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Navigation Bar
    
    private var navigationBar: some View {
        HStack(spacing: Spacing.medium) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Onlife Icon
            Image.onlifeIcon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 32)
            
            Spacer()
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, Spacing.medium)
        .padding(.bottom, Spacing.small)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        Text("Create your profile")
            .font(.system(size: 36, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Form Section
    
    private var formSection: some View {
        VStack(spacing: Spacing.medium) {
            // Username Field
            usernameField
            
            // Name Field
            nameField
            
            // Bio Field
            bioField
        }
    }
    
    private var usernameField: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("USERNAME")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray.opacity(0.7))
            
            TextField("e.g. jthorne_99", text: Binding(
                get: { store.username },
                set: { store.updateUsername($0) }
            ))
            .font(.body)
            .foregroundColor(.white)
            .focused($focusedField, equals: .username)
            #if os(iOS)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            #endif
            .padding()
            .background(Color.white.opacity(0.05))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        focusedField == .username ? primaryGradient : LinearGradient(
                            colors: [Color.white.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: focusedField == .username ? 2 : 1
                    )
            }
            .cornerRadius(12)
            
            // Validation Message
            if let validationMessage = store.usernameValidationMessage {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.8))
            }
        }
    }
    
    private var nameField: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("NAME")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray.opacity(0.7))
            
            TextField("e.g. Julian Thorne", text: Binding(
                get: { store.name },
                set: { store.updateName($0) }
            ))
            .font(.body)
            .foregroundColor(.white)
            .focused($focusedField, equals: .name)
            #if os(iOS)
            .textInputAutocapitalization(.words)
            #endif
            .padding()
            .background(Color.white.opacity(0.05))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        focusedField == .name ? primaryGradient : LinearGradient(
                            colors: [Color.white.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: focusedField == .name ? 2 : 1
                    )
            }
            .cornerRadius(12)
            
            // Validation Message
            if let validationMessage = store.nameValidationMessage {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.8))
            }
        }
    }
    
    private var bioField: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text("BIO")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray.opacity(0.7))
                
                Spacer()
                
                Text("OPTIONAL")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            ZStack(alignment: .topLeading) {
                // Placeholder
                if store.bio.isEmpty {
                    Text("Tell people a little about yourself...")
                        .font(.body)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                #if os(iOS)
                TextEditor(text: Binding(
                    get: { store.bio },
                    set: { store.updateBio($0) }
                ))
                .font(.body)
                .foregroundColor(.white)
                .focused($focusedField, equals: .bio)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: 80)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                #else
                TextEditor(text: Binding(
                    get: { store.bio },
                    set: { store.updateBio($0) }
                ))
                .font(.body)
                .foregroundColor(.white)
                .focused($focusedField, equals: .bio)
                .background(Color.clear)
                .frame(minHeight: 80)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                #endif
            }
            .background(Color.white.opacity(0.05))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        focusedField == .bio ? primaryGradient : LinearGradient(
                            colors: [Color.white.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: focusedField == .bio ? 2 : 1
                    )
            }
            .cornerRadius(12)
            
            // Character Count
            HStack {
                Spacer()
                Text(store.bioCharacterCount)
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        Button {
            Task {
                await store.createProfile()
            }
        } label: {
            buttonLabel
        }
        .disabled(store.isLoading || !store.isFormValid)
        .opacity(store.isFormValid ? 1.0 : 0.6)
    }
    
    private var buttonLabel: some View {
        HStack(spacing: Spacing.small) {
            if store.isLoading {
                ProgressView()
                    .tint(.black)
            } else {
                Text("CONTINUE")
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
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: Spacing.small) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            
            Circle()
                .fill(primaryGradient)
                .frame(width: 8, height: 8)
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
        }
    }
}

// MARK: - Preview

#Preview {
    CreateProfileView()
}
