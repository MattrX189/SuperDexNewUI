//
//  UserProfileData.swift
//  HomeScreen
//

import Foundation

struct UserProfileData: Codable, Equatable {
    var name: String = ""
    var jobRole: String = ""
    var bio: String = ""
    var phone: String = ""
    var email: String = ""
    var instagram: String = ""
    var linkedin: String = ""
    var x: String = ""
    var github: String = ""
    var themeIndex: Int = 0
    var avatar: String = "memoji1"

    init() {}

    var theme: CardTheme {
        CardTheme.themes[themeIndex % CardTheme.themes.count]
    }

    var asProfileCard: ProfileCard {
        ProfileCard(
            name: name.isEmpty ? "Your Name" : name,
            jobRole: jobRole,
            bio: bio,
            phone: phone,
            email: email,
            instagram: instagram,
            linkedin: linkedin,
            x: x,
            github: github,
            theme: theme,
            avatar: avatar
        )
    }
}
