//
//  SuperDexQRPayload.swift
//  SuperDex
//

import Foundation

struct SuperDexQRPayload: Codable {
    static let kindV1 = "superdex.profile.v1"

    let kind: String
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

    init(profile: ProfileCard) {
        self.kind = Self.kindV1
        self.name = profile.name
        self.jobRole = profile.jobRole
        self.bio = profile.bio
        self.phone = profile.phone
        self.email = profile.email
        self.instagram = profile.instagram
        self.linkedin = profile.linkedin
        self.x = profile.x
        self.github = profile.github
        self.themeName = profile.theme.name
        self.avatar = profile.avatar
    }

    func encodedString() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decode(from text: String) -> SuperDexQRPayload? {
        guard let data = text.data(using: .utf8),
              let payload = try? JSONDecoder().decode(SuperDexQRPayload.self, from: data),
              payload.kind == kindV1
        else { return nil }
        return payload
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

    var asContact: Contact {
        Contact(
            name: name,
            jobRole: jobRole,
            bio: bio,
            phone: phone,
            email: email,
            instagram: instagram,
            linkedin: linkedin,
            x: x,
            github: github,
            themeName: themeName,
            avatar: avatar
        )
    }
}
