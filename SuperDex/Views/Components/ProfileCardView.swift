//
//  ProfileCardView.swift
//  HomeScreen
//

import SwiftUI

struct ProfileCardView: View {
    let profile: ProfileCard

    @Environment(\.openURL) private var openURL
    @State private var showQRSheet = false

    private let cornerRadius: CGFloat = 32

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    var body: some View {
        ZStack {
            metallicBackground
            grainAndSheen
            contentLayer
        }
        .environment(\.colorScheme, .light)
        .clipShape(cardShape)
        .overlay(edgeStroke)
        .compositingGroup()
        .shadow(color: .black.opacity(0.55), radius: 28, y: 16)
        .shadow(
            color: (profile.theme.gradientColors.first ?? .purple).opacity(0.45),
            radius: 22, y: 10
        )
        .sheet(isPresented: $showQRSheet) {
            ProfileQRSheet(profile: profile)
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Metallic Background

    private var metallicBackground: some View {
        ZStack {
            profile.theme.gradientColors.first ?? .purple

            RadialGradient(
                colors: [
                    (profile.theme.gradientColors.first ?? .purple).opacity(0.0),
                    (profile.theme.gradientColors.first ?? .purple).opacity(0.9),
                    (profile.theme.gradientColors.dropFirst().first ?? .purple)
                ],
                center: UnitPoint(x: 0.25, y: 0.0),
                startRadius: 40,
                endRadius: 480
            )

            RadialGradient(
                colors: [
                    (profile.theme.gradientColors.last ?? .orange).opacity(0.95),
                    (profile.theme.gradientColors.last ?? .orange).opacity(0.35),
                    .clear
                ],
                center: UnitPoint(x: 0.8, y: 0.95),
                startRadius: 0,
                endRadius: 320
            )
            .blendMode(.plusLighter)
            .opacity(0.85)

            RadialGradient(
                colors: [.white.opacity(0.35), .white.opacity(0.08), .clear],
                center: UnitPoint(x: 0.15, y: 0.05),
                startRadius: 0,
                endRadius: 220
            )
            .blendMode(.plusLighter)
        }
    }

    private var grainAndSheen: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0.10), location: 0.0),
                    .init(color: .clear, location: 0.35),
                    .init(color: .black.opacity(0.18), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0.18), location: 0.0),
                    .init(color: .clear, location: 0.5),
                    .init(color: .white.opacity(0.06), location: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .blendMode(.softLight)
        }
    }

    private var edgeStroke: some View {
        cardShape
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(0.65),
                        .white.opacity(0.18),
                        .white.opacity(0.08),
                        .white.opacity(0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.2
            )
    }

    // MARK: - Content

    private var contentLayer: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                qrButton
            }
            .padding(.top, 18)
            .padding(.horizontal, 18)

            Spacer(minLength: 10)

            avatar

            Spacer().frame(height: 18)

            Text(profile.name)
                .font(.gilroy(.semiBold, size: 28))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)

            Spacer().frame(height: 4)

            Text(profile.jobRole.uppercased())
                .font(.gilroy(.semiBold, size: 11))
                .tracking(1.8)
                .foregroundStyle(.white.opacity(0.88))

            Spacer(minLength: 14)

            contactButtons

            Spacer(minLength: 10)

            brandRow
                .padding(.bottom, 20)
        }
    }

    private var qrButton: some View {
        Button {
            showQRSheet = true
        } label: {
            Image(systemName: "qrcode")
                .font(.gilroy(.semiBold, size: 16))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: Circle())
    }

    private var avatar: some View {
        Image(profile.avatar)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 96, height: 96)
            .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
    }

    private var contactButtons: some View {
        HStack(spacing: 18) {
            circularLink(
                icon: "phone.fill",
                urlString: "tel:\(profile.phone.replacingOccurrences(of: " ", with: ""))"
            )
            circularLink(
                icon: "envelope.fill",
                urlString: "mailto:\(profile.email)"
            )
        }
    }

    private func circularLink(icon: String, urlString: String) -> some View {
        Button {
            if let url = URL(string: urlString) { openURL(url) }
        } label: {
            Image(systemName: icon)
                .font(.gilroy(.semiBold, size: 26))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: Circle())
       
    }

    private var brandRow: some View {
        HStack(spacing: 0) {
            brandLink(name: "instagram", urlString: "https://instagram.com/\(profile.instagram.replacingOccurrences(of: "@", with: ""))")
            Spacer(minLength: 4)
            brandLink(name: "linkedin", urlString: "https://\(profile.linkedin)")
            Spacer(minLength: 4)
            brandLink(name: "x", urlString: "https://x.com/\(profile.x.replacingOccurrences(of: "@", with: ""))")
            Spacer(minLength: 4)
            brandLink(name: "github", urlString: "https://\(profile.github)")
        }
        .padding(.horizontal, 20)
    }

    private func brandLink(name: String, urlString: String) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        return Button {
            if let url = URL(string: urlString) { openURL(url) }
        } label: {
            BrandIcon(name: name)
                .frame(width: 22, height: 22)
                .frame(width: 46, height: 46)
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: shape)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ProfileCardView(profile: sampleProfiles[2])
            .frame(width: 300, height: 420)
    }
}
