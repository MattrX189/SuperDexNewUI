//
//  SuperDexApp.swift
//  SuperDex
//
//  Created by Gaurang Pant on 4/26/26.
//

import SwiftUI
import Auth

@main
struct CategoryCardsApp: App {
    @State private var splashFinished = false
    @State private var contentOpacity: Double = 0
    @State private var auth = AuthViewModel()
    @State private var userProfile = UserProfileViewModel()
    @State private var home = HomeViewModel()
    @State private var contacts = ContactsViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                rootContent
                    .opacity(contentOpacity)
                    .environment(auth)
                    .environment(userProfile)
                    .environment(home)
                    .environment(contacts)

                if !splashFinished {
                    SplashView(isFinished: $splashFinished)
                        .transition(.opacity)
                }
            }
            .task(id: auth.currentUser?.id) {
                if let user = auth.currentUser {
                    await userProfile.load(for: user)
                    await home.load(for: user)
                    await contacts.load(for: user)
                } else if case .signedOut = auth.state {
                    userProfile.clearOnSignOut()
                    home.clearOnSignOut()
                    contacts.clearOnSignOut()
                }
            }
            .onChange(of: splashFinished) { _, finished in
                guard finished else { return }
                withAnimation(.easeIn(duration: 1.2)) {
                    contentOpacity = 1
                }
            }
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        switch auth.state {
        case .loading:
            Color.black
        case .signedOut:
            LoginView()
        case .signedIn:
            ContentView()
        }
    }
}
