//
//  ProfileService.swift
//  SuperDex
//

import Foundation
import Supabase

struct ProfileService {
    private let client = SupabaseManager.client
    private let table = "profiles"

    func fetch(userId: UUID) async throws -> UserProfileData? {
        let rows: [ProfileRow] = try await client
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .limit(1)
            .execute()
            .value
        return rows.first?.toData()
    }

    func upsert(_ profile: UserProfileData, userId: UUID) async throws {
        let row = ProfileRow(userId: userId, profile: profile)
        try await client.from(table).upsert(row).execute()
    }
}

private struct ProfileRow: Codable {
    let user_id: UUID
    let name: String
    let job_role: String
    let bio: String
    let phone: String
    let email: String
    let instagram: String
    let linkedin: String
    let x: String
    let github: String
    let theme_index: Int
    let avatar: String

    init(userId: UUID, profile: UserProfileData) {
        self.user_id = userId
        self.name = profile.name
        self.job_role = profile.jobRole
        self.bio = profile.bio
        self.phone = profile.phone
        self.email = profile.email
        self.instagram = profile.instagram
        self.linkedin = profile.linkedin
        self.x = profile.x
        self.github = profile.github
        self.theme_index = profile.themeIndex
        self.avatar = profile.avatar
    }

    func toData() -> UserProfileData {
        var data = UserProfileData()
        data.name = name
        data.jobRole = job_role
        data.bio = bio
        data.phone = phone
        data.email = email
        data.instagram = instagram
        data.linkedin = linkedin
        data.x = x
        data.github = github
        data.themeIndex = theme_index
        data.avatar = avatar
        return data
    }
}
