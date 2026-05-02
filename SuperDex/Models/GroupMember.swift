//
//  GroupMember.swift
//  SuperDex
//

import Foundation

struct GroupMember: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var jobRole: String
    var bio: String
    var phone: String
    var email: String
    var instagram: String
    var linkedin: String
    var x: String
    var github: String
    var themeName: String
    var avatar: String

    init(
        id: UUID = UUID(),
        name: String,
        jobRole: String = "",
        bio: String = "",
        phone: String = "",
        email: String = "",
        instagram: String = "",
        linkedin: String = "",
        x: String = "",
        github: String = "",
        themeName: String = "",
        avatar: String = "memoji1"
    ) {
        self.id = id
        self.name = name
        self.jobRole = jobRole
        self.bio = bio
        self.phone = phone
        self.email = email
        self.instagram = instagram
        self.linkedin = linkedin
        self.x = x
        self.github = github
        self.themeName = themeName
        self.avatar = avatar
    }

    init(from profile: ProfileCard) {
        self.init(
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

    var asProfileCard: ProfileCard {
        ProfileCard(
            name: name,
            jobRole: jobRole,
            bio: bio,
            phone: phone,
            email: email,
            instagram: instagram,
            linkedin: linkedin,
            x: x,
            github: github,
            theme: CardTheme.named(themeName) ?? CardTheme.themes[0],
            avatar: avatar
        )
    }
}
