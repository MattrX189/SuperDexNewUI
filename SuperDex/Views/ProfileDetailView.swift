//
//  ProfileDetailView.swift
//  HomeScreen
//
//  Created by Gaurang Pant on 15/04/26.
//

import SwiftUI

struct ProfileDetailView: View {
    let profile: ProfileCard
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showSaveToContacts = false

    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabButton(title: "Profile", icon: "person.fill", isSelected: selectedTab == 0) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 0
                    }
                }
                
                TabButton(title: "History", icon: "calendar.badge.clock", isSelected: selectedTab == 1) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 1
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                profileTabContent
                    .tag(0)
                
                MeetingHistoryView(meetings: profile.meetings)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.gilroy(.semiBold, size: 16))
                        Text("Back")
                            .font(.gilroy(.regular, size: 17))
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSaveToContacts = true
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.gilroy(.semiBold, size: 18))
                }
                .accessibilityLabel("Save to Contacts")
            }
        }
        .sheet(isPresented: $showSaveToContacts) {
            SaveToContactsView(profile: profile) {
                showSaveToContacts = false
            }
            .ignoresSafeArea()
        }
    }
    
    private var profileTabContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ProfileCardView(profile: profile)
                    .aspectRatio(300.0 / 460.0, contentMode: .fit)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                VStack(alignment: .leading, spacing: 18) {
                    Text("Contact")
                        .font(.gilroy(.regular, size: 34))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 14),
                            GridItem(.flexible(), spacing: 14)
                        ],
                        spacing: 14
                    ) {
                        ContactTile(label: "Phone", value: profile.phone) {
                            if let url = URL(string: "tel:\(profile.phone.replacingOccurrences(of: " ", with: ""))") {
                                openURL(url)
                            }
                        } icon: {
                            Image(systemName: "phone")
                                .font(.gilroy(.regular, size: 20))
                                .foregroundStyle(.white)
                        }

                        ContactTile(label: "Email", value: profile.email) {
                            if let url = URL(string: "mailto:\(profile.email)") {
                                openURL(url)
                            }
                        } icon: {
                            Image(systemName: "envelope")
                                .font(.gilroy(.regular, size: 20))
                                .foregroundStyle(.white)
                        }

                        ContactTile(label: "Instagram", value: profile.instagram) {
                            if let url = URL(string: "https://instagram.com/\(profile.instagram.replacingOccurrences(of: "@", with: ""))") {
                                openURL(url)
                            }
                        } icon: {
                            BrandIcon(name: "instagram")
                        }

                        ContactTile(label: "LinkedIn", value: profile.linkedin) {
                            if let url = URL(string: "https://\(profile.linkedin)") {
                                openURL(url)
                            }
                        } icon: {
                            BrandIcon(name: "linkedin")
                        }

                        ContactTile(label: "X", value: profile.x) {
                            if let url = URL(string: "https://x.com/\(profile.x.replacingOccurrences(of: "@", with: ""))") {
                                openURL(url)
                            }
                        } icon: {
                            BrandIcon(name: "x")
                        }

                        ContactTile(label: "GitHub", value: profile.github) {
                            if let url = URL(string: "https://\(profile.github)") {
                                openURL(url)
                            }
                        } icon: {
                            BrandIcon(name: "github")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
        }
        .background(Color.black)
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.gilroy(.regular, size: 20))

                Text(title)
                    .font(.gilroy(.medium, size: 12))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            .background(
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(height: 2)
                        .opacity(isSelected ? 1 : 0)
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        ProfileDetailView(
            profile: ProfileCard(
                name: "Ben",
                jobRole: "iOS Developer",
                bio: "Building delightful apps one pixel at a time.",
                phone: "+1 (555) 100-2001",
                email: "ben@example.com",
                instagram: "@ben.dev",
                linkedin: "linkedin.com/in/ben",
                x: "@ben_dev",
                github: "github.com/ben",
                theme: .glacier,
                meetings: EventMeeting.sampleMeetings
            )
        )
    }
}
