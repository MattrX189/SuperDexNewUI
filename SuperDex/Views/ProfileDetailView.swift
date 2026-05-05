//
//  ProfileDetailView.swift
//  HomeScreen
//
//  Created by Gaurang Pant on 15/04/26.
//

import SwiftUI

struct ProfileDetailView: View {
    let profile: ProfileCard
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showSaveToContacts = false

    private var accent: Color {
        profile.theme.gradientColors.first ?? .purple
    }

    private var accentSecondary: Color {
        profile.theme.gradientColors.last ?? .purple
    }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundLayer

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                segmentedTabBar
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 14)

                Group {
                    if selectedTab == 0 {
                        profileTabContent
                    } else {
                        MeetingHistoryView(meetings: profile.meetings)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
        .sheet(isPresented: $showSaveToContacts) {
            SaveToContactsView(profile: profile) {
                showSaveToContacts = false
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .contentShape(Circle())
                    .glassEffect(.regular, in: Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                showSaveToContacts = true
            } label: {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .contentShape(Circle())
                    .glassEffect(.regular, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Save to Contacts")
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            AppBackground(showTopGlow: false)

            RadialGradient(
                colors: [
                    accent.opacity(0.55),
                    accent.opacity(0.18),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.0),
                startRadius: 20,
                endRadius: 520
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    accentSecondary.opacity(0.35),
                    .clear
                ],
                center: UnitPoint(x: 0.85, y: 0.18),
                startRadius: 10,
                endRadius: 360
            )
            .blendMode(.plusLighter)
            .ignoresSafeArea()
        }
    }

    // MARK: - Segmented Tab Bar

    private var segmentedTabBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "Profile", icon: "square.grid.2x2.fill", tag: 0)
            tabButton(title: "Activity", icon: "waveform.path.ecg", tag: 1)
        }
        .padding(4)
        .glassEffect(.regular, in: Capsule())
    }

    private func tabButton(title: String, icon: String, tag: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.22)) { selectedTab = tag }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.gilroy(.semiBold, size: 14))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .foregroundStyle(selectedTab == tag ? .white : Color.white.opacity(0.5))
            .background {
                if selectedTab == tag {
                    Capsule()
                        .fill(accent.opacity(0.7))
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Profile Tab

    private var profileTabContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                heroCard
                    .padding(.top, 4)

                identitySection

                if !profile.bio.isEmpty {
                    aboutSection
                }

                if !profile.phone.isEmpty || !profile.email.isEmpty {
                    contactSection
                }

                if !profile.allLinkEntries.isEmpty {
                    linksSection
                }

                connectionSection

                Color.clear.frame(height: 30)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        ProfileCardView(profile: profile)
            .aspectRatio(300.0 / 460.0, contentMode: .fit)
            .padding(.horizontal, 24)
            .shadow(color: accent.opacity(0.55), radius: 40, y: 18)
            .padding(.bottom, 10)
    }

    // MARK: - Identity (Name + Job Title)

    private var identitySection: some View {
        VStack(spacing: 6) {
            Text(profile.name)
                .font(.gilroy(.bold, size: 28))
                .foregroundStyle(.white)

            if !profile.jobRole.isEmpty {
                Text(profile.jobRole)
                    .font(.gilroy(.semiBold, size: 16))
                    .foregroundStyle(accent.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "About", count: nil)

            HStack(alignment: .top, spacing: 12) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [accent, accentSecondary.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3)
                    .clipShape(Capsule())

                Text(profile.bio)
                    .font(.gilroy(.medium, size: 15))
                    .foregroundStyle(Color.white.opacity(0.82))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    // MARK: - Contact

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Contact", count: nil)

            VStack(spacing: 0) {
                if !profile.phone.isEmpty {
                    contactRow(
                        icon: "phone.fill",
                        label: "Phone",
                        value: profile.phone,
                        action: {
                            let digits = profile.phone.filter { $0.isNumber || $0 == "+" }
                            if let url = URL(string: "tel:\(digits)") { openURL(url) }
                        }
                    )
                }

                if !profile.phone.isEmpty && !profile.email.isEmpty {
                    Divider()
                        .background(Color.white.opacity(0.08))
                        .padding(.horizontal, 16)
                }

                if !profile.email.isEmpty {
                    contactRow(
                        icon: "envelope.fill",
                        label: "Email",
                        value: profile.email,
                        action: {
                            if let url = URL(string: "mailto:\(profile.email)") { openURL(url) }
                        }
                    )
                }
            }
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func contactRow(icon: String, label: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.18))
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(accent)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.gilroy(.medium, size: 12))
                        .foregroundStyle(Color.white.opacity(0.5))
                    Text(value)
                        .font(.gilroy(.semiBold, size: 15))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Links

    private var linksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Links", count: "\(profile.allLinkEntries.count)")

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                ForEach(profile.allLinkEntries, id: \.self) { entry in
                    linkTile(entry)
                }
            }
        }
    }

    private func linkTile(_ entry: ProfileLinkEntry) -> some View {
        Button {
            if let url = entry.url { openURL(url) }
        } label: {
            HStack(spacing: 10) {
                LinkIcon(link: entry.link)
                    .frame(width: 22, height: 22)

                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.label)
                        .font(.gilroy(.semiBold, size: 13))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(entry.value)
                        .font(.gilroy(.medium, size: 11))
                        .foregroundStyle(Color.white.opacity(0.45))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Connection

    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Connection",
                count: profile.meetings.isEmpty ? nil : "\(profile.meetings.count)"
            )

            if profile.meetings.isEmpty {
                emptyConnectionCard
            } else {
                HStack(spacing: 10) {
                    StatPill(
                        value: "\(profile.meetings.count)",
                        label: profile.meetings.count == 1 ? "Meeting" : "Meetings"
                    )
                    StatPill(
                        value: firstMetText,
                        label: "First met"
                    )
                    StatPill(
                        value: lastMetText,
                        label: "Last met"
                    )
                }
            }
        }
    }

    private var emptyConnectionCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.18))
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(accent)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text("New connection")
                    .font(.gilroy(.bold, size: 15))
                    .foregroundStyle(.white)
                Text("Add a meeting from the Activity tab to track when and where you met.")
                    .font(.gilroy(.medium, size: 12))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, count: String?) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.gilroy(.bold, size: 18))
                .foregroundStyle(.white)

            if let count {
                Text(count)
                    .font(.gilroy(.semiBold, size: 12))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(Color.white.opacity(0.08))
                    )
            }

            Spacer()
        }
    }

    private var firstMetText: String {
        guard let date = profile.meetings.map(\.date).min() else { return "—" }
        return monthDayFormatter.string(from: date)
    }

    private var lastMetText: String {
        guard let date = profile.meetings.map(\.date).max() else { return "—" }
        return monthDayFormatter.string(from: date)
    }

    private var monthDayFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }
}

// MARK: - Stat Pill

private struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.gilroy(.bold, size: 18))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label.uppercased())
                .font(.gilroy(.semiBold, size: 9))
                .tracking(1.2)
                .foregroundStyle(Color.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        ProfileDetailView(
            profile: ProfileCard(
                name: "Ben",
                jobRole: "iOS Developer",
                bio: "Building delightful apps one pixel at a time.",
                phone: "+1 (555) 100-2001",
                email: "ben@example.com",
                instagram: "@ben.dev",
                linkedin: "linkedin.com/in/ben",
                x: "@ben_dev",
                github: "github.com/ben",
                theme: .glacier,
                meetings: EventMeeting.sampleMeetings
            )
        )
    }
}
