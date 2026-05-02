//
//  ContactTile.swift
//  HomeScreen
//

import SwiftUI

struct ContactTile<Icon: View>: View {
    let label: String
    let value: String
    let action: () -> Void
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 48, height: 48)
                    icon()
                        .frame(width: 20, height: 20)
                }

                Spacer(minLength: 36)

                Text(label)
                    .font(.gilroy(.regular, size: 16))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .padding(.bottom, 10)

                Text(value)
                    .font(.gilroy(.bold, size: 19))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, minHeight: 190, alignment: .leading)
            .padding(20)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
