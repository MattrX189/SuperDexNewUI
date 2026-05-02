//
//  MeetingHistoryView.swift
//  HomeScreen
//
//  Created by Gaurang Pant on 17/04/26.
//

import SwiftUI

struct MeetingHistoryView: View {
    let meetings: [EventMeeting]
    @State private var showingAddMeeting = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if meetings.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(meetings.sorted(by: { $0.date > $1.date })) { meeting in
                            MeetingCard(meeting: meeting)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .padding(.bottom, 80) // Space for floating action button
            }
            
            // Floating Action Button
            Button {
                showingAddMeeting = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.gilroy(.semiBold, size: 16))
                    Text("Add Meeting")
                        .font(.gilroy(.semiBold, size: 15))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color.accentColor)
                .clipShape(Capsule())
                .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .background(AppBackground())
        .sheet(isPresented: $showingAddMeeting) {
            AddMeetingView { newMeeting in
                // In a real app, you'd save this to your data model
                print("New meeting added: \(newMeeting.eventName)")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.gilroy(.regular, size: 60))
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            
            Text("No Past Meetings")
                .font(.gilroy(.semiBold, size: 22))

            Text("Your meeting history with this person will appear here")
                .font(.gilroy(.regular, size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct MeetingCard: View {
    let meeting: EventMeeting
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with event name and date
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(meeting.eventName)
                        .font(.gilroy(.semiBold, size: 17))

                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.gilroy(.regular, size: 12))
                        Text(meeting.location)
                            .font(.gilroy(.regular, size: 15))
                    }
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(meeting.formattedDate)
                    .font(.gilroy(.regular, size: 12))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
            }
            
            Divider()
            
            // Notes section
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "note.text")
                        .font(.gilroy(.regular, size: 12))
                    Text("Notes")
                        .font(.gilroy(.semiBold, size: 12))
                }
                .foregroundStyle(.secondary)

                Text(meeting.notes)
                    .font(.gilroy(.regular, size: 16))
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    MeetingHistoryView(meetings: EventMeeting.sampleMeetings)
}

#Preview("Empty State") {
    MeetingHistoryView(meetings: [])
}
