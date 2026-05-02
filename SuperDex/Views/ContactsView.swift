//
//  ContactsView.swift
//  HomeScreen
//

import SwiftUI

struct ContactsView: View {
    @Environment(ContactsViewModel.self) private var viewModel
    @State private var selectedContact: Contact?
    @State private var isSelecting: Bool = false
    @State private var selectedIds: Set<UUID> = []
    @State private var showAddToGroup: Bool = false
    @Namespace private var contactNamespace

    // How far the user has pulled past the top edge (0 when not overscrolling).
    // Drives the deck-fan physics on the stacked rows.
    @State private var pullStretch: CGFloat = 0

    private var contacts: [Contact] { viewModel.contacts }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 12)

                        if contacts.isEmpty {
                            emptyState
                                .padding(.top, 80)
                        } else {
                            LazyVStack(spacing: -40) {
                                ForEach(Array(contacts.enumerated()), id: \.element.id) { index, contact in
                                    ContactRow(
                                        contact: contact.asProfileCard,
                                        isSelecting: isSelecting,
                                        isSelected: selectedIds.contains(contact.id)
                                    )
                                    .matchedTransitionSource(id: contact.id, in: contactNamespace)
                                    .modifier(
                                        StackedDeckPhysics(
                                            index: index,
                                            stretch: pullStretch
                                        )
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if isSelecting {
                                            toggle(contact)
                                        } else {
                                            selectedContact = contact
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, isSelecting && !selectedIds.isEmpty ? 96 : 16)
                        }
                    }
                }
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    max(0, -(geometry.contentOffset.y + geometry.contentInsets.top))
                } action: { _, pulled in
                    pullStretch = pulled
                }
                .background(AppBackground())

                if isSelecting && !selectedIds.isEmpty {
                    addToGroupBar
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isSelecting)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedIds)
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedContact) { contact in
                ProfileDetailView(profile: contact.asProfileCard)
                    .navigationTransition(.zoom(sourceID: contact.id, in: contactNamespace))
            }
            .sheet(isPresented: $showAddToGroup) {
                AddToGroupSheet(members: selectedMembers) {
                    selectedIds.removeAll()
                    isSelecting = false
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Text("Contacts")
                .font(.gilroy(.bold, size: 42))
                .foregroundStyle(.white)

            Spacer()

            Button {
                withAnimation {
                    isSelecting.toggle()
                    if !isSelecting { selectedIds.removeAll() }
                }
            } label: {
                Text(isSelecting ? "Cancel" : "Select")
                    .font(.gilroy(.semiBold, size: 15))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(
                        Capsule().fill(Color.white.opacity(0.10))
                    )
                    .overlay(
                        Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Add-to-group action bar

    private var addToGroupBar: some View {
        Button {
            showAddToGroup = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.2.badge.plus.fill")
                    .font(.gilroy(.semiBold, size: 17))

                Text("Add \(selectedIds.count) to Group")
                    .font(.gilroy(.semiBold, size: 16))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.gilroy(.semiBold, size: 13))
                    .opacity(0.7)
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white)
            )
            .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Selection

    private func toggle(_ contact: Contact) {
        if selectedIds.contains(contact.id) {
            selectedIds.remove(contact.id)
        } else {
            selectedIds.insert(contact.id)
        }
    }

    private var selectedMembers: [GroupMember] {
        contacts
            .filter { selectedIds.contains($0.id) }
            .map { $0.asGroupMember }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.gilroy(.regular, size: 44))
                .foregroundStyle(.white.opacity(0.35))

            Text("No contacts yet")
                .font(.gilroy(.bold, size: 18))
                .foregroundStyle(.white.opacity(0.8))

            Text("Your saved contacts will appear here.")
                .font(.gilroy(.regular, size: 14))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }
}

// MARK: - Stacked Deck Physics

/// Spreads the stacked card deck on top-overscroll. Each card's spring response
/// is staggered by index so the deck cascades back into a stack on release.
private struct StackedDeckPhysics: ViewModifier {
    let index: Int
    let stretch: CGFloat

    // Saturating cap so the deck never fans wider than the original overlap —
    // cards always stay visually adjacent, no empty bands between them.
    private static let maxExtraGap: CGFloat = 32
    private static let stretchSoftness: CGFloat = 120

    func body(content: Content) -> some View {
        let depth = CGFloat(index)
        // Normalized 0…1 pull progress with an ease-out asymptote.
        let progress = min(stretch / Self.stretchSoftness, 1)
        // Each card drops further than the one above, but never past maxExtraGap.
        let extraGap = Self.maxExtraGap * progress
        let offsetY = depth * extraGap
        // Subtle scale up while the deck is fanned.
        let scale = 1 + 0.03 * progress

        content
            .offset(y: offsetY)
            .scaleEffect(scale, anchor: .top)
            .animation(
                .spring(
                    response: 0.45 + Double(index) * 0.025,
                    dampingFraction: 0.68
                ),
                value: stretch
            )
    }
}

struct ContactRow: View {
    let contact: ProfileCard
    var isSelecting: Bool = false
    var isSelected: Bool = false

    @Environment(\.openURL) private var openURL

    private let cornerRadius: CGFloat = 24

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            if isSelecting {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1)
                    .transition(.scale.combined(with: .opacity))
                    .padding(.top, 6)
            }

            Image(contact.avatar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 56, height: 56)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 3)

            VStack(alignment: .leading, spacing: 3) {
                Text(contact.name)
                    .font(.gilroy(.semiBold, size: 19))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                    .lineLimit(1)

                Text(contact.jobRole.uppercased())
                    .font(.gilroy(.semiBold, size: 10))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(1)

                if !contact.bio.isEmpty {
                    Text(contact.bio)
                        .font(.gilroy(.regular, size: 12))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.top, 2)
                }
            }
            .padding(.top, 2)

            Spacer(minLength: 4)

            if !isSelecting {
                HStack(spacing: 8) {
                    circularLink(icon: "phone.fill") {
                        if let url = URL(string: "tel:\(contact.phone.replacingOccurrences(of: " ", with: ""))") {
                            openURL(url)
                        }
                    }

                    circularLink(icon: "envelope.fill") {
                        if let url = URL(string: "mailto:\(contact.email)") {
                            openURL(url)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .frame(height: 134, alignment: .top)
        .background {
            ZStack {
                metallicBackground
                grainAndSheen
            }
        }
        .environment(\.colorScheme, .light)
        .clipShape(cardShape)
        .overlay(edgeStroke)
        .overlay(
            cardShape
                .strokeBorder(
                    isSelected ? Color.white.opacity(0.95) : .clear,
                    lineWidth: 2
                )
        )
        .compositingGroup()
        .shadow(color: .black.opacity(0.55), radius: 22, y: 14)
        .shadow(
            color: (contact.theme.gradientColors.first ?? .purple).opacity(0.35),
            radius: 18, y: 10
        )
        .animation(.easeInOut(duration: 0.2), value: isSelecting)
    }

    private func circularLink(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.gilroy(.semiBold, size: 18))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .glassEffect(.clear.interactive(), in: Circle())
    }

    // MARK: - Metallic Background (mirrors ProfileCardView)

    private var metallicBackground: some View {
        ZStack {
            contact.theme.gradientColors.first ?? .purple

            RadialGradient(
                colors: [
                    (contact.theme.gradientColors.first ?? .purple).opacity(0.0),
                    (contact.theme.gradientColors.first ?? .purple).opacity(0.9),
                    (contact.theme.gradientColors.dropFirst().first ?? .purple)
                ],
                center: UnitPoint(x: 0.25, y: 0.0),
                startRadius: 20,
                endRadius: 260
            )

            RadialGradient(
                colors: [
                    (contact.theme.gradientColors.last ?? .orange).opacity(0.95),
                    (contact.theme.gradientColors.last ?? .orange).opacity(0.35),
                    .clear
                ],
                center: UnitPoint(x: 0.85, y: 0.95),
                startRadius: 0,
                endRadius: 200
            )
            .blendMode(.plusLighter)
            .opacity(0.85)

            RadialGradient(
                colors: [.white.opacity(0.32), .white.opacity(0.06), .clear],
                center: UnitPoint(x: 0.12, y: 0.05),
                startRadius: 0,
                endRadius: 160
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
                lineWidth: 1.0
            )
    }
}

#Preview {
    let vm = ContactsViewModel()
    vm.contacts = sampleProfiles.map { profile in
        Contact(
            name: profile.name,
            jobRole: profile.jobRole,
            bio: profile.bio,
            phone: profile.phone,
            email: profile.email,
            instagram: profile.instagram,
            linkedin: profile.linkedin,
            x: profile.x,
            github: profile.github,
            themeName: profile.theme.name,
            avatar: profile.avatar
        )
    }
    return ContactsView()
        .environment(vm)
}

