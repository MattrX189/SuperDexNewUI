//
//  SplashView.swift
//  CategoryCards
//
//  Created by Gaurang Pant on 4/26/26.
//

import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool

    @State private var scale: CGFloat = 0.4
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            //AppBackground()

            Image("Splash")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .scaleEffect(scale)
        }
        .opacity(opacity)
        .task {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 1.0
            }
            try? await Task.sleep(for: .seconds(1.0))
            withAnimation(.easeInOut(duration: 0.5)) {
                opacity = 0
            }
            try? await Task.sleep(for: .seconds(0.5))
            isFinished = true
        }
    }
}

#Preview {
    SplashView(isFinished: .constant(false))
}
