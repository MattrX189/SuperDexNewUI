//
//  HProfileCardsView.swift
//  HomeScreen
//

import SwiftUI

struct HProfileCardView: View {
    let profile: ProfileCard

    var body: some View {
        ZStack {
            // Metallic base gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: profile.theme.gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Metallic shine overlay
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.4), location: 0.0),
                            .init(color: .clear, location: 0.2),
                            .init(color: .white.opacity(0.15), location: 0.5),
                            .init(color: .clear, location: 0.7),
                            .init(color: .black.opacity(0.2), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Metallic reflection spots
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .offset(x: -140, y: -40)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .offset(x: 140, y: 40)

            // Metallic border
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.6),
                            .white.opacity(0.2),
                            .white.opacity(0.4),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )

            HStack(spacing: 16) {
                // Left: Avatar, Name, Role
                VStack(spacing: 10) {
                    Image(profile.avatar)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1.2))
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

                    Text(profile.name)
                        .font(.gilroy(.bold, size: 17))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2, y: 1)

                    if !profile.jobRole.isEmpty {
                        Text(profile.jobRole)
                            .font(.gilroy(.medium, size: 11))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.22))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                                    )
                            )
                    }
                }
                .frame(width: 110)

                // Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.35), .white.opacity(0.12), .white.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1)
                    .padding(.vertical, 16)

                // Right: Bio, Actions, Socials
                VStack(alignment: .leading, spacing: 12) {
                    if !profile.bio.isEmpty {
                        Text(profile.bio)
                            .font(.gilroy(.regular, size: 15))
                            .foregroundStyle(.white.opacity(0.95))
                            .lineLimit(2)
                            .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
                    }

                    HStack(spacing: 10) {
                        SocialButton(
                            icon: .system("phone.fill"),
                            label: "Phone",
                            urlString: "tel:\(profile.phone.replacingOccurrences(of: " ", with: ""))"
                        )
                        SocialButton(
                            icon: .system("envelope.fill"),
                            label: "Email",
                            urlString: "mailto:\(profile.email)"
                        )
                    }

                    HStack(spacing: 10) {
                        SocialIconButton(icon: .brand("instagram"), urlString: "https://instagram.com/\(profile.instagram.replacingOccurrences(of: "@", with: ""))")
                        SocialIconButton(icon: .brand("linkedin"), urlString: "https://\(profile.linkedin)")
                        SocialIconButton(icon: .brand("x"), urlString: "https://x.com/\(profile.x.replacingOccurrences(of: "@", with: ""))")
                        SocialIconButton(icon: .brand("github"), urlString: "https://\(profile.github)")
                    }
                }
            }
            .padding(14)
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .compositingGroup()
        .shadow(color: .black.opacity(0.4), radius: 15, y: 8)
        .shadow(color: profile.theme.gradientColors.first?.opacity(0.5) ?? .black.opacity(0.3), radius: 10, y: 5)
    }
}

struct HProfileCardsView: View {
    let profiles: [ProfileCard]
    @Binding var selectedProfile: ProfileCard?

    init(profiles: [ProfileCard], selectedProfile: Binding<ProfileCard?> = .constant(nil)) {
        self.profiles = profiles
        _selectedProfile = selectedProfile
    }

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(profiles) { profile in
                HProfileCardView(profile: profile)
                    .padding(.horizontal, 8)
                    .onTapGesture {
                        selectedProfile = profile
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        HProfileCardsView(profiles: sampleProfiles)
            .navigationDestination(item: .constant(nil as ProfileCard?)) { profile in
                ProfileDetailView(profile: profile)
            }
            .background(Color(.systemGroupedBackground))
    }
}

