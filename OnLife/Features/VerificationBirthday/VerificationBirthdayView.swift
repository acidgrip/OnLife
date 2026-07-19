//
//  VerificationBirthdayView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI

struct VerificationBirthdayView: View {
    @State private var store = VerificationBirthdayStore()
    @Environment(\.dismiss) private var dismiss
    
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
                
                VStack(spacing: Spacing.large) {
                    Spacer()
                        .frame(height: Spacing.medium)
                    
                    // Title and Description
                    headerSection
                    
                    Spacer()
                        .frame(height: Spacing.extraLarge)
                    
                    // Date Display
                    dateDisplaySection
                    
                    Spacer()
                        .frame(height: Spacing.large)
                    
                    // Date Picker
                    datePickerSection
                    
                    Spacer()
                        .frame(height: Spacing.large)
                    
                    // Next Button
                    nextButton
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.large)
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .alert("Success", isPresented: $store.showSuccess) {
            Button("OK") {
                // TODO: Navigate to next step
                dismiss()
            }
        } message: {
            Text("Birthday verified successfully!")
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
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.35))
            }
            
            Spacer()
            
            Spacer()
                .frame(width: 44) // Balance the back button
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, Spacing.medium)
        .padding(.bottom, Spacing.small)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("When's your birthday?")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text("Your birthday won't be shown on your profile.")
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, Spacing.extraSmall)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Date Display Section
    
    private var dateDisplaySection: some View {
        HStack(spacing: Spacing.medium) {
            Image(systemName: "calendar")
                .font(.title2)
                .foregroundStyle(primaryGradient)
            
            Text(store.formattedDateString)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(Spacing.large)
        .background(Color.white.opacity(0.05))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
        .cornerRadius(12)
    }
    
    // MARK: - Date Picker Section
    
    private var datePickerSection: some View {
        DatePicker(
            "Select Birthday",
            selection: Binding(
                get: { store.selectedDate },
                set: { store.updateDate($0) }
            ),
            in: store.minimumDate...store.maximumDate,
            displayedComponents: .date
        )
        #if os(iOS)
        .datePickerStyle(.wheel)
        .colorScheme(.dark)
        #else
        .datePickerStyle(.graphical)
        #endif
        .labelsHidden()
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.small)
    }
    
    // MARK: - Next Button
    
    private var nextButton: some View {
        Button {
            Task {
                await store.submitBirthday()
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
                Text("Next")
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
}

// MARK: - Preview

#Preview {
    VerificationBirthdayView()
}
