//
//  UserProfileView.swift
//  HomeScreen
//

import SwiftUI

struct UserProfileView: View {
    @Environment(UserProfileViewModel.self) private var viewModel
    @Environment(AuthViewModel.self) private var auth
    @State private var selectedProfile: ProfileCard?

    var body: some View {
        @Bindable var viewModel = viewModel
        return NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        Text("My Profile")
                            .font(.gilroy(.bold, size: 42))
                            .foregroundStyle(.white)

                        Spacer()

                        Button {
                            viewModel.isEditing = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.gilroy(.semiBold, size: 20))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    ProfileCardView(profile: viewModel.profile.asProfileCard)
                        .aspectRatio(300.0 / 460.0, contentMode: .fit)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedProfile = viewModel.profile.asProfileCard
                        }

                    optionsSection
                        .padding(.horizontal, 20)
                        .padding(.top, 28)

                    footerSection
                        .padding(.top, 36)
                        .padding(.bottom, 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedProfile) { profile in
                ProfileDetailView(profile: profile)
            }
            .sheet(isPresented: $viewModel.isEditing) {
                EditProfileView(profile: $viewModel.profile) {
                    viewModel.saveProfile()
                }
            }
            .onChange(of: viewModel.profile) {
                viewModel.saveProfile()
            }
        }
    }

    // MARK: - Options

    private var optionsSection: some View {
        VStack(spacing: 10) {
            optionRow(
                title: "Request a Feature",
                systemImage: "lightbulb.fill"
            ) {
                // TODO: open feature request flow
            }

            optionRow(
                title: "Terms & Conditions",
                systemImage: "doc.text.fill"
            ) {
                // TODO: open terms
            }

            optionRow(
                title: "Privacy Policy",
                systemImage: "lock.shield.fill"
            ) {
                // TODO: open privacy policy
            }

            logoutRow
        }
    }

    private var logoutRow: some View {
        Button {
            Task { await auth.signOut() }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.red.opacity(0.18))
                    if auth.isWorking {
                        ProgressView()
                            .tint(.red)
                    } else {
                        Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.red)
                    }
                }
                .frame(width: 32, height: 32)

                Text("Log Out")
                    .font(.gilroy(.semiBold, size: 16))
                    .foregroundStyle(.red)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.red.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.red.opacity(0.20), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(auth.isWorking)
    }

    private func optionRow(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 32, height: 32)

                Text(title)
                    .font(.gilroy(.semiBold, size: 16))
                    .foregroundStyle(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 4) {
            Text("v1.8.9 (In Dev)")
                .font(.gilroy(.medium, size: 13))
                .foregroundStyle(.white.opacity(0.45))

            Text("Developed by")
                .font(.gilroy(.medium, size: 13))
                .foregroundStyle(.white.opacity(0.55))

            Image("MattrTextLogo")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(height: 90)
                .padding(.top, -28)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    UserProfileView()
        .environment(AuthViewModel())
        .environment(UserProfileViewModel())
}
