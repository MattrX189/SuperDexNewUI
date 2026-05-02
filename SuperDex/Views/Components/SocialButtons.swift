//
//  SocialButtons.swift
//  HomeScreen
//

import SwiftUI

enum SocialIconType {
    case system(String)
    case brand(String)
}

struct SocialButton: View {
    @Environment(\.openURL) private var openURL
    let icon: SocialIconType
    let label: String
    var urlString: String = ""
    @State private var isPressed = false

    var body: some View {
        Button {
            if let url = URL(string: urlString) {
                openURL(url)
            }
        } label: {
            HStack(spacing: 6) {
                Group {
                    switch icon {
                    case .system(let name):
                        Image(systemName: name)
                            .font(.gilroy(.semiBold, size: 14))
                    case .brand(let name):
                        BrandIcon(name: name)
                    }
                }
                .frame(width: 18, height: 18)

                Text(label)
                    .font(.gilroy(.semiBold, size: 13))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                ZStack {
                    // Base frosted glass with color tint
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.white.opacity(0.15))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    
                    // Top highlight for glass effect
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.4), location: 0),
                                    .init(color: .white.opacity(0.2), location: 0.3),
                                    .init(color: .clear, location: 0.5)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Soft border
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(.white.opacity(0.3), lineWidth: 1.5)
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
    }
}

struct SocialIconButton: View {
    @Environment(\.openURL) private var openURL
    let icon: SocialIconType
    var urlString: String = ""
    @State private var isPressed = false

    var body: some View {
        Button {
            if let url = URL(string: urlString) {
                openURL(url)
            }
        } label: {
            Group {
                switch icon {
                case .system(let name):
                    Image(systemName: name)
                        .font(.gilroy(.semiBold, size: 16))
                case .brand(let name):
                    BrandIcon(name: name)
                }
            }
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(
                ZStack {
                    // Base frosted glass with color tint
                    Circle()
                        .fill(.white.opacity(0.15))
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                    
                    // Top highlight for glass shine
                    Circle()
                        .fill(
                            RadialGradient(
                                stops: [
                                    .init(color: .white.opacity(0.5), location: 0),
                                    .init(color: .white.opacity(0.2), location: 0.4),
                                    .init(color: .clear, location: 0.8)
                                ],
                                center: UnitPoint(x: 0.35, y: 0.35),
                                startRadius: 0,
                                endRadius: 22
                            )
                        )
                    
                    // Soft border
                    Circle()
                        .strokeBorder(.white.opacity(0.3), lineWidth: 1.5)
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
    }
}
