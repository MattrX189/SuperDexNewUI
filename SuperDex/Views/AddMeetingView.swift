//
//  AddMeetingView.swift
//  HomeScreen
//
//  Created by Gaurang Pant on 17/04/26.
//

import SwiftUI

struct AddMeetingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var eventName = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var notes = ""
    
    let onSave: (EventMeeting) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Event Name", text: $eventName)
                    TextField("Location", text: $location)
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Add Meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let meeting = EventMeeting(
                            eventName: eventName,
                            location: location,
                            date: date,
                            notes: notes
                        )
                        onSave(meeting)
                        dismiss()
                    }
                    .disabled(eventName.isEmpty || location.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddMeetingView { meeting in
        print("Saved: \(meeting.eventName)")
    }
}
