//
//  GroupDetailView.swift
//  HomeScreen
//

import SwiftUI

struct GroupDetailView: View {
    let group: CardGroup
    @Binding var selectedProfile: ProfileCard?
    var onEdit: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var isListLayout = false

    private var members: [ProfileCard] { group.profileCards }
    private var memberCount: Int { members.count }

    private var wallpaperImage: UIImage? {
        guard let data = group.wallpaperData else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    Color.clear.frame(height: 56)

                    heroCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, wallpaperImage == nil ? 0 : 8)

                    titleSection
                        .padding(.horizontal, 22)

                    actionToggle
                        .padding(.horizontal, 20)
                        .padding(.top, wallpaperImage == nil ? 0 : 6)

                    profilesSection
                        .padding(.top, 4)
                        .padding(.bottom, 56)
                }
                .frame(maxWidth: .infinity)
            }

            topBar
                .padding(.horizontal, 20)
                .padding(.top, 4)
        }
        .background {
            pageBackground
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }

    // MARK: - Page background

    @ViewBuilder
    private var pageBackground: some View {
        if let img = wallpaperImage {
            ZStack {
                Color.black

                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .blur(radius: 90, opaque: true)

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.05),
                        Color.black.opacity(0.30),
                        Color.black.opacity(0.65)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        } else {
            ZStack {
                Color(red: 0.04, green: 0.05, blue: 0.09)

                LinearGradient(
                    colors: [
                        group.color.opacity(0.55),
                        group.color.opacity(0.20),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )

                RadialGradient(
                    colors: [group.color.opacity(0.30), .clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 420
                )
            }
        }
    }

    // MARK: - Top bar

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
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .contentShape(Circle())
                    .glassEffect(.regular, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Hero card (square, locked to its allocated width)

    private var heroCard: some View {
        GeometryReader { proxy in
            let side = proxy.size.width
            ZStack(alignment: .bottom) {
                heroBackground(side: side)

                heroForeground(side: side)

                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.35)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: side, height: 80)
                .allowsHitTesting(false)

                heroBadge
                    .frame(width: side)
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.50), radius: 24, y: 14)
    }

    @ViewBuilder
    private func heroBackground(side: CGFloat) -> some View {
        if let img = wallpaperImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(width: side, height: side)
                .clipped()
                .blur(radius: 40, opaque: true)
                .scaleEffect(1.08)
                .frame(width: side, height: side)
                .clipped()
                .allowsHitTesting(false)
        } else {
            ZStack {
                LinearGradient(
                    colors: [group.color, group.color.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [.white.opacity(0.18), .clear],
                    center: UnitPoint(x: 0.2, y: 0.2),
                    startRadius: 0,
                    endRadius: 220
                )
            }
            .frame(width: side, height: side)
        }
    }

    @ViewBuilder
    private func heroForeground(side: CGFloat) -> some View {
        if let img = wallpaperImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .frame(width: side, height: side)
                .allowsHitTesting(false)
        } else {
            Image(systemName: group.icon)
                .font(.system(size: 90, weight: .bold))
                .foregroundStyle(.white.opacity(0.35))
                .frame(width: side, height: side)
        }
    }

    private var heroBadge: some View {
        HStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))

            Text("\(memberCount) MEMBERS")
                .font(.gilroy(.semiBold, size: 12))
                .tracking(2.2)
                .foregroundStyle(.white)

            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(wallpaperImage != nil ? group.color.opacity(0.55) : group.color.opacity(0.45))
        .background(.ultraThinMaterial)
    }

    // MARK: - Title section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(group.name)
                .font(.gilroy(.bold, size: 32))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let desc = group.descriptionText, !desc.isEmpty {
                descriptionCard(desc)
            }
            metaPills
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var metaPills: some View {
        HStack(spacing: 8) {
            metaPill(
                icon: "person.2.fill",
                text: "\(memberCount) \(memberCount == 1 ? "member" : "members")"
            )
            if let date = group.eventDate {
                metaPill(icon: "calendar", text: dateString(date))
                metaPill(icon: "clock", text: timeString(date))
            }
        }
    }

    private func metaPill(icon: String, text: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(group.color)
            Text(text)
                .font(.gilroy(.semiBold, size: 13))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .glassEffect(.regular, in: Capsule())
    }

    private func descriptionCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.gilroy(.semiBold, size: 18))
                .foregroundStyle(.white.opacity(0.55))

            Text(text)
                .font(.gilroy(.medium, size: 15))
                .foregroundStyle(.white.opacity(0.85))
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    // MARK: - Action toggle (Cards / List)

    private var actionToggle: some View {
        HStack(spacing: 10) {
            actionButton(
                title: "Cards",
                systemImage: "rectangle.portrait.on.rectangle.portrait.fill",
                isSelected: !isListLayout
            ) {
                if isListLayout {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        isListLayout = false
                    }
                }
            }
            .frame(maxWidth: .infinity)

            actionButton(
                title: "List",
                systemImage: "rectangle.grid.1x2.fill",
                isSelected: isListLayout
            ) {
                if !isListLayout {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        isListLayout = true
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func actionButton(
        title: String,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let label = VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? Color.black.opacity(0.88) : Color.white.opacity(0.20))
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 30, height: 30)

            Text(title)
                .font(.gilroy(.semiBold, size: 14))
                .foregroundStyle(isSelected ? .black : .white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .contentShape(Rectangle())

        if isSelected {
            Button(action: action) { label }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
                )
        } else {
            Button(action: action) { label }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    // MARK: - Profiles

    @ViewBuilder
    private var profilesSection: some View {
        if members.isEmpty {
            emptyMembersState
                .padding(.horizontal, 24)
                .padding(.top, 12)
        } else if isListLayout {
            HProfileCardsView(profiles: members, selectedProfile: $selectedProfile)
                .transition(.opacity)
        } else {
            ProfileCardsView(profiles: members, selectedProfile: $selectedProfile)
                .frame(height: 460)
                .transition(.opacity)
        }
    }

    private var emptyMembersState: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))
            Text("No members yet")
                .font(.gilroy(.semiBold, size: 16))
                .foregroundStyle(.white)
            Text("Add contacts from the Contacts tab to see them here.")
                .font(.gilroy(.regular, size: 13))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        GroupDetailView(
            group: CardGroup(
                name: "First Sip at RWA House",
                colorName: "purple",
                icon: "sparkles",
                descriptionText: "Join us for early morning coffee, conversations, and connections with fellow founders building the future.",
                eventDate: Date()
            ),
            selectedProfile: .constant(nil)
        )
    }
    .preferredColorScheme(.dark)
}
