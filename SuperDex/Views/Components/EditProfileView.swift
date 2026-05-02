//
//  EditProfileView.swift
//  HomeScreen
//

import SwiftUI

struct EditProfileView: View {
    @Binding var profile: UserProfileData
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    private static let memojis: [String] = (1...7).map { "memoji\($0)" }

    var body: some View {
        NavigationStack {
            Form {
                Section("Memoji") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Self.memojis, id: \.self) { name in
                                let isSelected = profile.avatar == name
                                Image(name)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 64, height: 64)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                isSelected ? Color.accentColor : Color.white.opacity(0.15),
                                                lineWidth: isSelected ? 3 : 1
                                            )
                                    )
                                    .shadow(
                                        color: isSelected ? Color.accentColor.opacity(0.5) : .clear,
                                        radius: 6
                                    )
                                    .scaleEffect(isSelected ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.18), value: isSelected)
                                    .contentShape(Circle())
                                    .onTapGesture {
                                        profile.avatar = name
                                    }
                                    .accessibilityLabel("Memoji \(name.dropFirst("memoji".count))")
                                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 6)
                    }
                }

                Section("Personal") {
                    EditField(label: "Name", text: $profile.name, icon: "person.fill")
                    EditField(label: "Job Role", text: $profile.jobRole, icon: "briefcase.fill")
                    EditField(label: "Bio", text: $profile.bio, icon: "text.quote")
                }

                Section("Contact") {
                    EditField(label: "Phone", text: $profile.phone, icon: "phone.fill", keyboard: .phonePad)
                    EditField(label: "Email", text: $profile.email, icon: "envelope.fill", keyboard: .emailAddress)
                }

                Section("Social") {
                    EditField(label: "Instagram", text: $profile.instagram, icon: "camera.fill")
                    EditField(label: "LinkedIn", text: $profile.linkedin, icon: "person.2.fill")
                    EditField(label: "X", text: $profile.x, icon: "at")
                    EditField(label: "GitHub", text: $profile.github, icon: "terminal.fill")
                }

                Section("Theme") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<CardTheme.themes.count, id: \.self) { index in
                                let theme = CardTheme.themes[index]
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: theme.gradientColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.white, lineWidth: profile.themeIndex == index ? 3 : 0)
                                    )
                                    .shadow(color: profile.themeIndex == index ? theme.accentColor.opacity(0.5) : .clear, radius: 6)
                                    .onTapGesture {
                                        profile.themeIndex = index
                                    }
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 14) {
                            ForEach(0..<CardTheme.themes.count, id: \.self) { index in
                                let theme = CardTheme.themes[index]
                                let isSelected = profile.themeIndex == index
                                VStack(spacing: 8) {
                                    ThemePreviewCard(
                                        profile: profile,
                                        theme: theme,
                                        isSelected: isSelected
                                    )
                                    Text(theme.name)
                                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                                        .foregroundStyle(isSelected ? .primary : .secondary)
                                }
                                .onTapGesture {
                                    profile.themeIndex = index
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct ThemePreviewCard: View {
    let profile: UserProfileData
    let theme: CardTheme
    let isSelected: Bool

    private let cornerRadius: CGFloat = 18

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    var body: some View {
        ZStack {
            background
            sheen
            content
        }
        .frame(width: 132, height: 176)
        .clipShape(shape)
        .overlay(
            shape.strokeBorder(
                isSelected ? Color.white : Color.white.opacity(0.18),
                lineWidth: isSelected ? 2.5 : 1
            )
        )
        .shadow(
            color: isSelected
                ? theme.accentColor.opacity(0.55)
                : .black.opacity(0.25),
            radius: isSelected ? 10 : 5,
            y: 4
        )
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private var background: some View {
        ZStack {
            theme.gradientColors.first ?? .purple

            RadialGradient(
                colors: [
                    (theme.gradientColors.first ?? .purple).opacity(0.0),
                    (theme.gradientColors.first ?? .purple).opacity(0.9),
                    theme.gradientColors.dropFirst().first ?? .purple
                ],
                center: UnitPoint(x: 0.25, y: 0.0),
                startRadius: 12,
                endRadius: 180
            )

            RadialGradient(
                colors: [
                    (theme.gradientColors.last ?? .orange).opacity(0.95),
                    (theme.gradientColors.last ?? .orange).opacity(0.3),
                    .clear
                ],
                center: UnitPoint(x: 0.8, y: 0.95),
                startRadius: 0,
                endRadius: 140
            )
            .blendMode(.plusLighter)
            .opacity(0.85)
        }
    }

    private var sheen: some View {
        LinearGradient(
            stops: [
                .init(color: .white.opacity(0.18), location: 0.0),
                .init(color: .clear, location: 0.5),
                .init(color: .black.opacity(0.18), location: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var content: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            Image(profile.avatar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

            Spacer().frame(height: 8)

            Text(profile.name.isEmpty ? "Your Name" : profile.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 8)

            Spacer().frame(height: 2)

            Text((profile.jobRole.isEmpty ? "Job Role" : profile.jobRole).uppercased())
                .font(.system(size: 7, weight: .semibold))
                .tracking(1.0)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
                .padding(.horizontal, 8)

            Spacer(minLength: 12)

            HStack(spacing: 10) {
                miniGlassIcon("phone.fill")
                miniGlassIcon("envelope.fill")
            }

            Spacer(minLength: 14)
        }
        .environment(\.colorScheme, .light)
    }

    private func miniGlassIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 26, height: 26)
            .background(.white.opacity(0.18), in: Circle())
            .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 0.5))
    }
}

struct EditField: View {
    let label: String
    @Binding var text: String
    let icon: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            TextField(label, text: $text)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
    }
}
