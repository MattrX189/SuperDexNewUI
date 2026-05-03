//
//  HomeView.swift
//  HomeScreen
//

import SwiftUI

struct HomeView: View {
    @Environment(HomeViewModel.self) private var viewModel
    @Environment(UserProfileViewModel.self) private var profileVM

    private var userProfile: UserProfileData { profileVM.profile }

    var body: some View {
        @Bindable var viewModel = viewModel
        return NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        header
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        // Search Bar (original position in flow)
                        searchBar
                            .padding(.horizontal, 16)
                            .padding(.top, 28)

                        // Content
                        Group {
                            if viewModel.groups.isEmpty {
                                VStack { Spacer(minLength: 80); emptyState; Spacer(minLength: 80) }
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.groups) { group in
                                        NavigationLink(value: group) {
                                            GroupCardView(group: group)
                                        }
                                        .buttonStyle(GroupCardPressStyle())
                                        .contextMenu {
                                            Button {
                                                viewModel.groupBeingEdited = group
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }

                                            Button(role: .destructive) {
                                                viewModel.groupPendingDeletion = group
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 120)
                            }
                        }
                    }
                }

                floatingPlusButton
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
            }
            .background(AppBackground())
            .navigationBarHidden(true)
            .navigationDestination(for: CardGroup.self) { group in
                GroupDetailView(
                    group: group,
                    selectedProfile: $viewModel.selectedProfile,
                    onEdit: { viewModel.groupBeingEdited = group }
                )
            }
            .navigationDestination(item: $viewModel.selectedProfile) { profile in
                ProfileDetailView(profile: profile)
            }
            .sheet(isPresented: $viewModel.showingNewGroupSheet) {
                NewGroupView { name, description, date, wallpaperData, members in
                    viewModel.createGroup(
                        name: name,
                        description: description,
                        eventDate: date,
                        wallpaperData: wallpaperData,
                        members: members
                    )
                }
            }
            .sheet(item: $viewModel.groupBeingEdited) { group in
                NewGroupView(existingGroup: group) { name, description, date, wallpaperData, _ in
                    viewModel.updateGroup(
                        id: group.id,
                        name: name,
                        description: description,
                        eventDate: date,
                        wallpaperData: wallpaperData
                    )
                }
            }
            .alert(
                "Delete Group?",
                isPresented: Binding(
                    get: { viewModel.groupPendingDeletion != nil },
                    set: { if !$0 { viewModel.groupPendingDeletion = nil } }
                ),
                presenting: viewModel.groupPendingDeletion
            ) { group in
                Button("Delete", role: .destructive) {
                    viewModel.deleteGroup(id: group.id)
                }
                Button("Cancel", role: .cancel) {}
            } message: { group in
                Text("\"\(group.name)\" will be permanently deleted. This cannot be undone.")
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("SUPERDEX")
                    .font(.gilroy(.semiBold, size: 12))
                    .tracking(2.4)
                    .foregroundStyle(.white.opacity(0.55))

                VStack(alignment: .leading, spacing: -4) {
                    Text("Hello")
                        .font(.gilroy(.bold, size: 42))
                        .foregroundStyle(.white)
                    Text("\(greetingName)!")
                        .font(.gilroy(.bold, size: 42))
                        .foregroundStyle(.white)
                }
            }

            Spacer()

            Button {
                viewModel.selectedProfile = userProfile.asProfileCard
            } label: {
                Image(userProfile.avatar)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(
                        Circle().strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
        }
    }

    private var greetingName: String {
        let trimmed = userProfile.name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "there" }
        return trimmed.split(separator: " ").first.map(String.init) ?? trimmed
    }

    // MARK: - Search

    private var searchBar: some View {
        @Bindable var viewModel = viewModel
        return HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.gilroy(.semiBold, size: 16))
                .foregroundStyle(.white.opacity(0.55))

            TextField("", text: $viewModel.searchText, prompt:
                Text("Search people, roles, events…")
                    .font(.gilroy(.regular, size: 15))
                    .foregroundColor(.white.opacity(0.45))
            )
            .font(.gilroy(.regular, size: 15))
            .foregroundStyle(.white)
            .tint(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.03))
        )
        .overlay(
            Capsule()
                .strokeBorder(.white.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 28) {
            Image("empty")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140)
                .opacity(0.9)

            emptyStateText
                .font(.gilroy(.regular, size: 15))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .frame(maxWidth: 300)
                .padding(.horizontal, 32)
        }
    }

    private var emptyStateText: Text {
        Text("No group added yet, use ")
        + Text(Image(systemName: "plus.circle.fill")).foregroundColor(.blue)
        + Text(" button to create\nnew group with people")
    }

    // MARK: - Floating + button

    private var floatingPlusButton: some View {
        Button {
            viewModel.prepareNewGroup()
        } label: {
            Image(systemName: "plus")
                .font(.gilroy(.bold, size: 22))
                .foregroundStyle(.black)
                .frame(width: 56, height: 56)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.white.opacity(0.3), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Font helper

extension Font {
    enum GilroyWeight: String {
        case light = "Gilroy-Light"
        case regular = "Gilroy-Regular"
        case medium = "Gilroy-Medium"
        case semiBold = "Gilroy-SemiBold"
        case bold = "Gilroy-Bold"
        case extraBold = "Gilroy-ExtraBold"

        var systemWeight: Font.Weight {
            switch self {
            case .light: return .light
            case .regular: return .regular
            case .medium: return .medium
            case .semiBold: return .semibold
            case .bold: return .bold
            case .extraBold: return .heavy
            }
        }

        var fontNameFallbacks: [String] {
            switch self {
            case .light: return ["Gilroy-Light"]
            case .regular: return ["Gilroy-Regular"]
            case .medium: return ["Gilroy-Medium", "Gilroy-Regular"]
            case .semiBold: return ["Gilroy-SemiBold", "Gilroy-Bold", "Gilroy-Medium"]
            case .bold: return ["Gilroy-Bold"]
            case .extraBold: return ["Gilroy-ExtraBold", "Gilroy-Heavy", "Gilroy-Bold"]
            }
        }
    }

    static func gilroy(_ weight: GilroyWeight, size: CGFloat) -> Font {
        for name in weight.fontNameFallbacks where UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: weight.systemWeight, design: .rounded)
    }
}

#Preview {
    HomeView()
        .environment(UserProfileViewModel())
        .environment(HomeViewModel())
        .preferredColorScheme(.dark)
}
