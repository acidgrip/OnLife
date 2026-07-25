//
//  AddPhotosView.swift
//  Onlife
//
//  Created by Daniel Lee on 6/14/26.
//

import SwiftUI
import PhotosUI

struct AddPhotosView: View {
    let session: SignUpSession
    @State private var store: AddPhotosStore
    @State private var profilePhotoPickerItem: PhotosPickerItem?
    @State private var publicPhotoPickerItem: PhotosPickerItem?
    @State private var privatePhotoPickerItem: PhotosPickerItem?
    @State private var navigateToCreateProfile = false

    @Environment(\.dismiss) private var dismiss

    init(session: SignUpSession) {
        self.session = session
        _store = State(initialValue: AddPhotosStore(session: session))
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
                    // Title & Description
                    headerSection

                    // Photo Grid
                    photoGrid

                    Spacer()

                    // Upload Button
                    uploadButton
                }
                .padding(.horizontal, Spacing.large)
                .padding(.top, Spacing.small)

                // Progress Indicator
                progressIndicator
                    .padding(.bottom, Spacing.large)
                    .padding(.top, Spacing.medium)
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .navigationDestination(isPresented: $navigateToCreateProfile) {
            CreateProfileView(session: session)
        }
        .onChange(of: profilePhotoPickerItem) { _, newItem in
            Task {
                await store.selectProfilePhoto(from: newItem)
                profilePhotoPickerItem = nil
            }
        }
        .onChange(of: publicPhotoPickerItem) { _, newItem in
            Task {
                await store.selectPublicPhoto(from: newItem)
                publicPhotoPickerItem = nil
            }
        }
        .onChange(of: privatePhotoPickerItem) { _, newItem in
            if let index = store.selectedPrivatePhotoIndex {
                Task {
                    await store.selectPrivatePhoto(from: newItem, at: index)
                    privatePhotoPickerItem = nil
                    store.selectedPrivatePhotoIndex = nil
                }
            }
        }
        .onChange(of: store.showSuccess) { oldValue, newValue in
            if newValue {
                navigateToCreateProfile = true
            }
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
        VStack(alignment: .leading, spacing: Spacing.extraSmall) {
            Text("Add photos")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("Your profile photo and 1 photo are public. Additional photos are only visible to your connections.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        HStack(alignment: .top, spacing: Spacing.small) {
            // Left side - Profile Photo
            profilePhotoCard

            // Right side - Public and Private photos
            VStack(spacing: Spacing.small) {
                publicPhotoCard
                privatePhotosGrid
            }
        }
    }

    // MARK: - Profile Photo Card

    private var profilePhotoCard: some View {
        VStack(spacing: Spacing.extraSmall) {
            PhotosPicker(selection: $profilePhotoPickerItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .aspectRatio(0.75, contentMode: .fit)

                    if let photoItem = store.profilePhoto {
                        #if os(iOS)
                        Image(uiImage: photoItem.image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        #else
                        Image(nsImage: photoItem.image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        #endif
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray.opacity(0.3))
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if store.profilePhoto != nil {
                        Button {
                            store.removeProfilePhoto()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding(8)
                    }
                }
            }

            Text("PROFILE PHOTO")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.gray.opacity(0.7))
                .tracking(0.5)
        }
    }

    // MARK: - Public Photo Card

    private var publicPhotoCard: some View {
        VStack(spacing: Spacing.extraSmall) {
            PhotosPicker(selection: $publicPhotoPickerItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .aspectRatio(1.0, contentMode: .fit)

                    if let photoItem = store.publicPhoto {
                        #if os(iOS)
                        Image(uiImage: photoItem.image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        #else
                        Image(nsImage: photoItem.image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        #endif
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if store.publicPhoto != nil {
                        Button {
                            store.removePublicPhoto()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding(6)
                    }
                }
            }

            Text("PUBLIC PHOTO")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.gray.opacity(0.7))
                .tracking(0.5)
        }
    }

    // MARK: - Private Photos Grid

    private var privatePhotosGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.extraSmall) {
            ForEach(0..<4, id: \.self) { index in
                privatePhotoCard(at: index)
            }
        }
    }

    private func privatePhotoCard(at index: Int) -> some View {
        PhotosPicker(
            selection: $privatePhotoPickerItem,
            matching: .images
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .aspectRatio(1.0, contentMode: .fit)

                if let photoItem = store.privatePhotos[index] {
                    #if os(iOS)
                    Image(uiImage: photoItem.image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    #else
                    Image(nsImage: photoItem.image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    #endif
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .overlay(alignment: .topTrailing) {
                if store.privatePhotos[index] != nil {
                    Button {
                        store.removePrivatePhoto(at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding(4)
                }
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            store.selectedPrivatePhotoIndex = index
        })
    }

    // MARK: - Upload Button

    private var uploadButton: some View {
        Button {
            Task {
                await store.uploadPhotos()
            }
        } label: {
            buttonLabel
        }
        .disabled(!store.isFormValid)
        .opacity(store.isFormValid ? 1.0 : 0.6)
    }

    private var buttonLabel: some View {
        HStack(spacing: Spacing.small) {
            if store.isLoading {
                ProgressView()
                    .tint(.black)
            } else {
                Text("UPLOAD PHOTOS")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(primaryGradient)
        .foregroundColor(.black)
        .cornerRadius(25)
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
                .fill(Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)

            Circle()
                .fill(primaryGradient)
                .frame(width: 8, height: 8)
        }
    }
}

// MARK: - Preview

#Preview {
    AddPhotosView(session: SignUpSession())
}
