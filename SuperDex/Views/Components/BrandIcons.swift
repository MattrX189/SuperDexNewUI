//
//  BrandIcons.swift
//  HomeScreen
//

import SwiftUI

struct BrandIcon: View {
    let name: String

    var body: some View {
        switch name {
        case "instagram":
            InstagramIcon()
        case "linkedin":
            LinkedInIcon()
        case "x":
            XIcon()
        case "github":
            GitHubIcon()
        default:
            EmptyView()
        }
    }
}

// MARK: - Instagram (white camera outline)

struct InstagramIcon: View {
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            let stroke = s * 0.11

            ZStack {
                RoundedRectangle(cornerRadius: s * 0.28, style: .continuous)
                    .stroke(Color.white, lineWidth: stroke)
                    .padding(stroke / 2)

                Circle()
                    .stroke(Color.white, lineWidth: stroke)
                    .frame(width: s * 0.46, height: s * 0.46)

                Circle()
                    .fill(Color.white)
                    .frame(width: s * 0.1, height: s * 0.1)
                    .position(x: s * 0.76, y: s * 0.24)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - LinkedIn (white "in")

struct LinkedInIcon: View {
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            Text("in")
                .font(.gilroy(.extraBold, size: s * 0.82))
                .foregroundStyle(.white)
                .frame(width: s, height: s)
                .baselineOffset(-s * 0.04)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - X (white stroke)

struct XIcon: View {
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            Canvas { ctx, _ in
                let t = s * 0.14
                let inset = s * 0.14
                var p1 = Path()
                p1.move(to: CGPoint(x: inset, y: inset))
                p1.addLine(to: CGPoint(x: s - inset, y: s - inset))
                var p2 = Path()
                p2.move(to: CGPoint(x: s - inset, y: inset))
                p2.addLine(to: CGPoint(x: inset, y: s - inset))
                ctx.stroke(p1, with: .color(.white), style: StrokeStyle(lineWidth: t, lineCap: .butt))
                ctx.stroke(p2, with: .color(.white), style: StrokeStyle(lineWidth: t, lineCap: .butt))
            }
            .frame(width: s, height: s)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - GitHub (white Octocat)

struct GitHubIcon: View {
    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            OctocatShape()
                .fill(Color.white)
                .frame(width: s, height: s)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// Official GitHub Octocat mark — transcribed from the 16×16 reference SVG.
private struct OctocatShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / 16
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: x * scale, y: y * scale)
        }

        var path = Path()
        path.move(to: p(8, 0))
        path.addCurve(to: p(0, 8), control1: p(3.58, 0), control2: p(0, 3.58))
        path.addCurve(to: p(5.47, 15.59), control1: p(0, 11.54), control2: p(2.29, 14.53))
        path.addCurve(to: p(6.02, 15.21), control1: p(5.87, 15.66), control2: p(6.02, 15.42))
        path.addCurve(to: p(6.01, 13.72), control1: p(6.02, 15.02), control2: p(6.01, 14.39))
        path.addCurve(to: p(3.32, 12.78), control1: p(4.00, 14.09), control2: p(3.48, 13.23))
        path.addCurve(to: p(2.50, 11.65), control1: p(3.23, 12.55), control2: p(2.84, 11.84))
        path.addCurve(to: p(2.49, 11.12), control1: p(2.22, 11.50), control2: p(1.82, 11.13))
        path.addCurve(to: p(3.72, 11.94), control1: p(3.12, 11.11), control2: p(3.57, 11.70))
        path.addCurve(to: p(6.05, 12.60), control1: p(4.44, 13.15), control2: p(5.59, 12.81))
        path.addCurve(to: p(6.56, 11.53), control1: p(6.12, 12.08), control2: p(6.33, 11.73))
        path.addCurve(to: p(2.92, 7.58), control1: p(4.78, 11.33), control2: p(2.92, 10.64))
        path.addCurve(to: p(3.74, 5.43), control1: p(2.92, 6.71), control2: p(3.23, 5.99))
        path.addCurve(to: p(3.82, 3.31), control1: p(3.66, 5.23), control2: p(3.38, 4.41))
        path.addCurve(to: p(6.02, 4.13), control1: p(3.82, 3.31), control2: p(4.49, 3.10))
        path.addCurve(to: p(8.02, 3.86), control1: p(6.66, 3.95), control2: p(7.34, 3.86))
        path.addCurve(to: p(10.02, 4.13), control1: p(8.70, 3.86), control2: p(9.38, 3.95))
        path.addCurve(to: p(12.22, 3.31), control1: p(11.55, 3.09), control2: p(12.22, 3.31))
        path.addCurve(to: p(12.30, 5.43), control1: p(12.66, 4.41), control2: p(12.38, 5.23))
        path.addCurve(to: p(13.12, 7.58), control1: p(12.81, 5.99), control2: p(13.12, 6.71))
        path.addCurve(to: p(9.47, 11.53), control1: p(13.12, 10.65), control2: p(11.25, 11.33))
        path.addCurve(to: p(10.01, 13.01), control1: p(9.76, 11.78), control2: p(10.01, 12.26))
        path.addCurve(to: p(10.00, 15.21), control1: p(10.01, 14.08), control2: p(10.00, 14.94))
        path.addCurve(to: p(10.55, 15.59), control1: p(10.00, 15.42), control2: p(10.15, 15.67))
        path.addCurve(to: p(16, 8), control1: p(13.71, 14.53), control2: p(16, 11.54))
        path.addCurve(to: p(8, 0), control1: p(16, 3.58), control2: p(12.42, 0))
        path.closeSubpath()

        return path
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple, .pink, .orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        HStack(spacing: 16) {
            ForEach(["instagram", "linkedin", "x", "github"], id: \.self) { name in
                BrandIcon(name: name)
                    .frame(width: 26, height: 26)
                    .padding(10)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    )
            }
        }
    }
}
