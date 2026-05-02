//
//  ProfileCardsView.swift
//  HomeScreen
//

import SwiftUI

struct ProfileCardsView: View {
    @State private var viewModel: ProfileCardsViewModel
    @Binding var selectedProfile: ProfileCard?

    init(profiles: [ProfileCard], selectedProfile: Binding<ProfileCard?> = .constant(nil)) {
        _viewModel = State(initialValue: ProfileCardsViewModel(profiles: profiles))
        _selectedProfile = selectedProfile
    }

    var body: some View {
        GeometryReader { geo in
            let containerWidth = geo.size.width
            let containerHeight = geo.size.height

            let centerWidth = min(300, containerWidth * 0.72)
            let centerHeight = min(420, containerHeight * 0.95)

            let sidePeek: CGFloat = max(24, containerWidth * 0.08)
            let sideScale: CGFloat = 0.9
            let sideYOffset: CGFloat = 18

            ZStack {
                ForEach(Array(viewModel.profiles.enumerated()), id: \.element.id) { idx, profile in
                    let relative = viewModel.relativePosition(of: idx)
                    let isCenter = relative == 0

                    let baseX: CGFloat = {
                        switch relative {
                        case 0: return 0
                        case -1: return -((centerWidth / 2) + sidePeek)
                        case 1: return (centerWidth / 2) + sidePeek
                        default:
                            return relative < 0 ? -containerWidth : containerWidth
                        }
                    }()

                    let dragX = isCenter ? viewModel.dragOffset.width : 0
                    let scale: CGFloat = isCenter ? 1.0 : sideScale
                    let yOffset: CGFloat = isCenter ? 0 : sideYOffset
                    let opacity: Double = abs(relative) <= 1 ? 1.0 : 0.0

                    ProfileCardView(profile: profile)
                        .frame(width: centerWidth, height: centerHeight)
                        .scaleEffect(scale)
                        .offset(x: baseX + dragX, y: yOffset)
                        .opacity(opacity)
                        .allowsHitTesting(isCenter)
                        .onTapGesture {
                            if isCenter { selectedProfile = profile }
                        }
                        .gesture(
                            isCenter ? DragGesture()
                                .onChanged { value in
                                    viewModel.dragOffset = value.translation
                                }
                                .onEnded { value in
                                    viewModel.handleDragEnd(translation: value.translation.width, cardWidth: centerWidth)
                                }
                            : nil
                        )
                        .zIndex(viewModel.zIndex(for: relative))
                        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: viewModel.currentIndex)
                        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.dragOffset)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .overlay(alignment: .leading) {
                Button(action: {
                    viewModel.swipeRight(cardWidth: centerWidth)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.gilroy(.semiBold, size: 16))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: Circle())
                .environment(\.colorScheme, .light)
                .padding(.leading, 8)
                .opacity(viewModel.currentIndex > 0 ? 1 : 0.4)
            }
            .overlay(alignment: .trailing) {
                Button(action: {
                    viewModel.swipeLeft(cardWidth: centerWidth)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.gilroy(.semiBold, size: 16))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: Circle())
                .environment(\.colorScheme, .light)
                .padding(.trailing, 8)
                .opacity(viewModel.currentIndex < viewModel.profiles.count - 1 ? 1 : 0.4)
            }
        }
    }
}

#Preview {
    ProfileCardsView(profiles: sampleProfiles)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
}
