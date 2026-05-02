//
//  ProfileQRSheet.swift
//  SuperDex
//

import SwiftUI

struct ProfileQRSheet: View {
    let profile: ProfileCard

    @State private var viewModel = QRCodeViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: profile.theme.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Capsule()
                    .fill(.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                Spacer(minLength: 8)

                Text(profile.name)
                    .font(.gilroy(.bold, size: 26))
                    .foregroundStyle(.white)

                if !profile.jobRole.isEmpty {
                    Text(profile.jobRole)
                        .font(.gilroy(.medium, size: 14))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }

                if let qrImage = viewModel.generateQRCode(for: profile) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .padding(20)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.15), radius: 18, y: 8)
                }

                Text("Scan with SuperDex to add as contact")
                    .font(.gilroy(.regular, size: 13))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ProfileQRSheet(profile: sampleProfiles[0])
}
