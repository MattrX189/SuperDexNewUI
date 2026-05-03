//
//  NewGroupView.swift
//  HomeScreen
//

import SwiftUI
import PhotosUI

struct NewGroupView: View {
    let existingGroup: CardGroup?
    var initialMembers: [GroupMember] = []
    var onSave: (_ name: String, _ description: String?, _ date: Date?, _ wallpaperData: Data?, _ members: [GroupMember]) -> Void

    init(
        existingGroup: CardGroup? = nil,
        initialMembers: [GroupMember] = [],
        onSave: @escaping (_ name: String, _ description: String?, _ date: Date?, _ wallpaperData: Data?, _ members: [GroupMember]) -> Void
    ) {
        self.existingGroup = existingGroup
        self.initialMembers = existingGroup?.members ?? initialMembers
        self.onSave = onSave

        _name = State(initialValue: existingGroup?.name ?? "")
        _descriptionText = State(initialValue: existingGroup?.descriptionText ?? "")
        _includeDate = State(initialValue: existingGroup?.eventDate != nil)
        _date = State(initialValue: existingGroup?.eventDate ?? Date())
        _wallpaperData = State(initialValue: existingGroup?.wallpaperData)
        _previewColorName = State(initialValue: existingGroup?.colorName ?? CardGroup.colorNames.randomElement() ?? "blue")
        _previewIcon = State(initialValue: existingGroup?.icon ?? CardGroup.icons.randomElement() ?? "folder.fill")
    }

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var descriptionText: String
    @State private var includeDate: Bool
    @State private var date: Date
    @State private var wallpaperItem: PhotosPickerItem?
    @State private var wallpaperData: Data?

    @State private var previewColorName: String
    @State private var previewIcon: String

    @FocusState private var focusedField: Field?

    private enum Field { case name, description }

    private var isEditing: Bool { existingGroup != nil }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private var canSave: Bool { !trimmedName.isEmpty }

    private var previewGroup: CardGroup {
        CardGroup(
            id: existingGroup?.id ?? UUID(),
            name: trimmedName.isEmpty ? "Group Name" : trimmedName,
            colorName: previewColorName,
            icon: previewIcon,
            descriptionText: descriptionText.trimmingCharacters(in: .whitespaces).isEmpty ? nil : descriptionText,
            eventDate: includeDate ? date : nil,
            wallpaperData: wallpaperData,
            members: initialMembers
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        previewSection
                            .padding(.top, 8)

                        formSection(title: "GROUP NAME", required: true) {
                            nameField
                        }

                        formSection(title: "DESCRIPTION") {
                            descriptionField
                        }

                        formSection(title: "DATE & TIME") {
                            dateRow
                        }

                        formSection(title: "WALLPAPER") {
                            wallpaperRow
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(isEditing ? "Edit Group" : "New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white.opacity(0.75))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Create") {
                        onSave(
                            trimmedName,
                            descriptionText.trimmingCharacters(in: .whitespaces),
                            includeDate ? date : nil,
                            wallpaperData,
                            initialMembers
                        )
                        dismiss()
                    }
                    .font(.gilroy(.semiBold, size: 15))
                    .foregroundStyle(canSave ? .white : .white.opacity(0.3))
                    .disabled(!canSave)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color(red: 0.04, green: 0.05, blue: 0.09)

            RadialGradient(
                colors: [previewGroup.color.opacity(0.30), .clear],
                center: UnitPoint(x: 0.0, y: 0.0),
                startRadius: 0,
                endRadius: 420
            )

            RadialGradient(
                colors: [previewGroup.color.opacity(0.18), .clear],
                center: UnitPoint(x: 1.0, y: 0.2),
                startRadius: 0,
                endRadius: 360
            )
        }
        .animation(.easeInOut(duration: 0.4), value: previewColorName)
    }

    // MARK: - Preview

    private var previewSection: some View {
        VStack(spacing: 14) {
            Text("LIVE PREVIEW")
                .font(.gilroy(.semiBold, size: 10))
                .tracking(2.0)
                .foregroundStyle(.white.opacity(0.45))

            GroupCardView(group: previewGroup, onTap: {})
                .allowsHitTesting(false)
        }
    }

    // MARK: - Section Helper

    private func formSection<Content: View>(
        title: String,
        required: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.gilroy(.semiBold, size: 11))
                    .tracking(1.8)
                    .foregroundStyle(.white.opacity(0.55))

                if required {
                    Text("•  REQUIRED")
                        .font(.gilroy(.semiBold, size: 10))
                        .tracking(1.2)
                        .foregroundStyle(previewGroup.color.opacity(0.95))
                }

                Spacer()
            }
            .padding(.horizontal, 4)

            content()
        }
    }

    // MARK: - Name field

    private var nameField: some View {
        HStack(spacing: 12) {
            Image(systemName: "textformat")
                .font(.gilroy(.semiBold, size: 15))
                .foregroundStyle(.white.opacity(0.55))
                .frame(width: 22)

            TextField(
                "",
                text: $name,
                prompt: Text("e.g. OpenAI, Anthropic, Design Team")
                    .font(.gilroy(.regular, size: 15))
                    .foregroundColor(.white.opacity(0.35))
            )
            .font(.gilroy(.semiBold, size: 16))
            .foregroundStyle(.white)
            .tint(previewGroup.color)
            .focused($focusedField, equals: .name)
            .submitLabel(.next)
            .onSubmit { focusedField = .description }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(fieldBackground(focused: focusedField == .name))
    }

    // MARK: - Description field

    private var descriptionField: some View {
        ZStack(alignment: .topLeading) {
            if descriptionText.isEmpty {
                Text("Add a short description… (optional)")
                    .font(.gilroy(.regular, size: 15))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
            }

            TextEditor(text: $descriptionText)
                .font(.gilroy(.regular, size: 15))
                .foregroundStyle(.white)
                .tint(previewGroup.color)
                .focused($focusedField, equals: .description)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minHeight: 80)
        }
        .background(fieldBackground(focused: focusedField == .description))
    }

    // MARK: - Date row

    private var dateRow: some View {
        VStack(spacing: 0) {
            Toggle(isOn: $includeDate.animation(.spring(response: 0.35, dampingFraction: 0.85))) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.gilroy(.semiBold, size: 15))
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(width: 22)

                    Text(includeDate ? "Date & time set" : "Add a date & time")
                        .font(.gilroy(.medium, size: 15))
                        .foregroundStyle(.white.opacity(0.95))
                }
            }
            .tint(previewGroup.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if includeDate {
                Divider()
                    .background(Color.white.opacity(0.08))
                    .padding(.horizontal, 12)

                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .tint(previewGroup.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(fieldBackground(focused: false))
    }

    // MARK: - Wallpaper row

    private var wallpaperRow: some View {
        PhotosPicker(selection: $wallpaperItem, matching: .images, photoLibrary: .shared()) {
            ZStack {
                if let data = wallpaperData, let uiImage = UIImage(data: data) {
                    ZStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .clipped()

                        LinearGradient(
                            colors: [.black.opacity(0.0), .black.opacity(0.55)],
                            startPoint: .top,
                            endPoint: .bottom
                        )

                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        wallpaperData = nil
                                        wallpaperItem = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.gilroy(.semiBold, size: 12))
                                        .foregroundStyle(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Color.black.opacity(0.55))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                            Spacer()
                            HStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .font(.gilroy(.semiBold, size: 12))
                                Text("Tap to replace")
                                    .font(.gilroy(.medium, size: 12))
                                Spacer()
                            }
                            .foregroundStyle(.white.opacity(0.9))
                        }
                        .padding(12)
                    }
                    .frame(height: 140)
                    .clipped()
                } else {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(previewGroup.color.opacity(0.18))
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.gilroy(.semiBold, size: 18))
                                .foregroundStyle(previewGroup.color)
                        }
                        .frame(width: 44, height: 44)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Upload wallpaper")
                                .font(.gilroy(.semiBold, size: 15))
                                .foregroundStyle(.white)
                            Text("Tap to choose from your photos")
                                .font(.gilroy(.regular, size: 12))
                                .foregroundStyle(.white.opacity(0.55))
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.gilroy(.semiBold, size: 12))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .frame(maxWidth: .infinity)
            .background(fieldBackground(focused: false))
        }
        .buttonStyle(.plain)
        .onChange(of: wallpaperItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            wallpaperData = data
                        }
                    }
                }
            }
        }
    }

    // MARK: - Field background

    private func fieldBackground(focused: Bool) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        focused ? previewGroup.color.opacity(0.7) : .white.opacity(0.10),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .animation(.easeInOut(duration: 0.2), value: focused)
    }
}

#Preview {
    Color.black
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            NewGroupView { _, _, _, _, _ in }
        }
        .preferredColorScheme(.dark)
}
