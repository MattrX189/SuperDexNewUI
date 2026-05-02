//
//  ContactService.swift
//  SuperDex
//

import Foundation
import Supabase

struct ContactService {
    private let client = SupabaseManager.client
    private let table = "contacts"

    func fetchAll(userId: UUID) async throws -> [Contact] {
        let rows: [ContactRecord] = try await client
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: true)
            .execute()
            .value
        return rows.map { $0.toContact() }
    }

    func upsert(_ contact: Contact, userId: UUID) async throws {
        let row = ContactRecord(userId: userId, contact: contact)
        try await client.from(table).upsert(row).execute()
    }
}

private struct ContactRecord: Codable {
    let id: UUID
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
    let theme_name: String
    let avatar: String

    init(userId: UUID, contact: Contact) {
        self.id = contact.id
        self.user_id = userId
        self.name = contact.name
        self.job_role = contact.jobRole
        self.bio = contact.bio
        self.phone = contact.phone
        self.email = contact.email
        self.instagram = contact.instagram
        self.linkedin = contact.linkedin
        self.x = contact.x
        self.github = contact.github
        self.theme_name = contact.themeName
        self.avatar = contact.avatar
    }

    func toContact() -> Contact {
        Contact(
            id: id,
            name: name,
            jobRole: job_role,
            bio: bio,
            phone: phone,
            email: email,
            instagram: instagram,
            linkedin: linkedin,
            x: x,
            github: github,
            themeName: theme_name,
            avatar: avatar
        )
    }
}
