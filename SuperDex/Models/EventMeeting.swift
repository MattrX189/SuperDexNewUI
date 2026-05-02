//
//  EventMeeting.swift
//  HomeScreen
//
//  Created by Gaurang Pant on 17/04/26.
//

import Foundation

struct EventMeeting: Identifiable, Hashable {
    let id = UUID()
    let eventName: String
    let location: String
    let date: Date
    let notes: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Sample meeting data for testing
extension EventMeeting {
    static let sampleMeetings: [EventMeeting] = [
        EventMeeting(
            eventName: "Tech Conference 2026",
            location: "San Francisco, CA",
            date: Date().addingTimeInterval(-30 * 24 * 60 * 60), // 30 days ago
            notes: "Discussed new iOS features and best practices. Very insightful conversation about SwiftUI performance optimization."
        ),
        EventMeeting(
            eventName: "Developer Meetup",
            location: "Local Coffee Shop",
            date: Date().addingTimeInterval(-60 * 24 * 60 * 60), // 60 days ago
            notes: "Shared ideas about app architecture. Talked about their experience with Swift concurrency."
        ),
        EventMeeting(
            eventName: "WWDC Watch Party",
            location: "Apple Park Visitor Center",
            date: Date().addingTimeInterval(-90 * 24 * 60 * 60), // 90 days ago
            notes: "First time meeting! Very enthusiastic about new Apple frameworks. We bonded over our love for SwiftUI."
        )
    ]
}
