//
//  GroupService.swift
//  SuperDex
//

import Foundation
import Supabase

struct GroupService {
    private let client = SupabaseManager.client
    private let table = "groups"

    func fetchAll(userId: UUID) async throws -> [CardGroup] {
        let rows: [GroupRow] = try await client
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: true)
            .execute()
            .value
        return rows.map { $0.toCardGroup() }
    }

    func upsert(_ group: CardGroup, userId: UUID) async throws {
        let row = GroupRow(userId: userId, group: group)
        try await client.from(table).upsert(row).execute()
    }
}

private struct GroupRow: Codable {
    let id: UUID
    let user_id: UUID
    let name: String
    let color_name: String
    let icon: String
    let description_text: String?
    let event_date: Date?
    let wallpaper_data: String?
    let members: [GroupMember]

    init(userId: UUID, group: CardGroup) {
        self.id = group.id
        self.user_id = userId
        self.name = group.name
        self.color_name = group.colorName
        self.icon = group.icon
        self.description_text = group.descriptionText
        self.event_date = group.eventDate
        self.wallpaper_data = group.wallpaperData?.base64EncodedString()
        self.members = group.members
    }

    func toCardGroup() -> CardGroup {
        CardGroup(
            id: id,
            name: name,
            colorName: color_name,
            icon: icon,
            descriptionText: description_text,
            eventDate: event_date,
            wallpaperData: wallpaper_data.flatMap { Data(base64Encoded: $0) },
            members: members
        )
    }
}
