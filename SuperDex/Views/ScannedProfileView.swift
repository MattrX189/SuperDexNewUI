//
//  ScannedProfileView.swift
//  SuperDex
//

import SwiftUI

struct ScannedProfileView: View {
    let payload: SuperDexQRPayload

    @Environment(ContactsViewModel.self) private var contactsVM
    @Environment(\.dismiss) private var dismiss

    @State private var isSaving = false
    @State private var saveState: SaveState = .idle

    enum SaveState {
        case idle, saving, saved, failed(String)
    }

    private var profile: ProfileCard { payload.asProfileCard }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileCardView(profile: profile)
                        .aspectRatio(300.0 / 460.0, contentMode: .fit)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    saveButton
                        .padding(.horizontal, 20)

                    if case .failed(let message) = saveState {
                        Text(message)
                            .font(.gilroy(.regular, size: 13))
                            .foregroundStyle(.red.opacity(0.85))
                            .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 24)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Scanned Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            Task { await save() }
        } label: {
            HStack(spacing: 10) {
                if case .saving = saveState {
                    ProgressView()
                        .tint(.black)
                } else {
                    Image(systemName: saveIcon)
                        .font(.gilroy(.semiBold, size: 17))
                }

                Text(saveLabel)
                    .font(.gilroy(.semiBold, size: 16))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white)
            )
        }
        .buttonStyle(.plain)
        .disabled(isSaveDisabled)
    }

    private var saveIcon: String {
        if case .saved = saveState { return "checkmark.circle.fill" }
        return "person.crop.circle.badge.plus"
    }

    private var saveLabel: String {
        switch saveState {
        case .idle: return "Save to My Contacts"
        case .saving: return "Saving…"
        case .saved: return "Saved"
        case .failed: return "Try Again"
        }
    }

    private var isSaveDisabled: Bool {
        switch saveState {
        case .saving, .saved: return true
        default: return false
        }
    }

    private func save() async {
        saveState = .saving
        let ok = await contactsVM.add(payload.asContact)
        if ok {
            saveState = .saved
        } else {
            saveState = .failed(contactsVM.errorMessage ?? "Failed to save contact.")
        }
    }
}
