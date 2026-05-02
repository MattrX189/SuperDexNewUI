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
                segmentedTabBar
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 14)

                TabView(selection: $selectedTab) {
                    profileTabContent
                        .tag(0)

                    MeetingHistoryView(meetings: profile.meetings)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.gilroy(.semiBold, size: 15))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .glassEffect(.clear.interactive(), in: Circle())
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSaveToContacts = true
                } label: {
                    Image(systemName: "bookmark")
                        .font(.gilroy(.semiBold, size: 15))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .glassEffect(.clear.interactive(), in: Circle())
                }
                .accessibilityLabel("Save to Contacts")
            }
        }
        .sheet(isPresented: $showSaveToContacts) {
            SaveToContactsView(profile: profile) {
                showSaveToContacts = false
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            Color.black.ignoresSafeArea()

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
        HStack(spacing: 6) {
            SegmentPill(
                title: "Profile",
                icon: "square.grid.2x2.fill",
                isSelected: selectedTab == 0,
                accent: accent
            ) {
                withAnimation(.easeInOut(duration: 0.22)) { selectedTab = 0 }
            }

            SegmentPill(
                title: "Activity",
                icon: "waveform.path.ecg",
                isSelected: selectedTab == 1,
                accent: accent
            ) {
                withAnimation(.easeInOut(duration: 0.22)) { selectedTab = 1 }
            }
        }
        .padding(5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Profile Tab

    private var profileTabContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                heroCard
                    .padding(.top, 4)

                if !profile.bio.isEmpty {
                    aboutSection
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
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
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
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(0.18))
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(accent.opacity(0.35), lineWidth: 1)
                Image(systemName: "sparkles")
                    .font(.gilroy(.semiBold, size: 18))
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
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
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

// MARK: - Segment Pill

private struct SegmentPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.gilroy(.semiBold, size: 13))
                Text(title)
                    .font(.gilroy(.semiBold, size: 14))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .foregroundStyle(isSelected ? .white : Color.white.opacity(0.55))
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [accent, accent.opacity(0.75)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: accent.opacity(0.55), radius: 12, y: 4)
                    }
                }
            )
        }
        .buttonStyle(.plain)
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
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
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
