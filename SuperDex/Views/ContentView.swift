//
//  ContentView.swift
//  HomeScreen
//  testable file
//  Created by Gaurang Pant on 15/04/26.
//

import SwiftUI

struct ContentView: View {
    private enum TabKind: Hashable { case home, contacts, profile, scan }

    @State private var selectedTab: TabKind = .home
    @State private var isScanning: Bool = false
    @State private var scannedPayload: RootScannedPayload?
    @State private var unrecognizedCode: RootScannedQRCode?

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: TabKind.home) {
                HomeView()
            }
            Tab("Contacts", systemImage: "person.2.fill", value: TabKind.contacts) {
                ContactsView()
            }
            Tab("Profile", systemImage: "person.fill", value: TabKind.profile) {
                UserProfileView()
            }
            Tab("Scan", systemImage: "qrcode.viewfinder", value: TabKind.scan, role: .search) {
                Color.clear
            }
        }
        .tint(.white)
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) { oldValue, newValue in
            guard newValue == .scan else { return }
            DispatchQueue.main.async {
                selectedTab = oldValue == .scan ? .home : oldValue
                isScanning = true
            }
        }
        .qrScanner(isScanning: $isScanning) { code in
            if let payload = SuperDexQRPayload.decode(from: code) {
                scannedPayload = RootScannedPayload(payload: payload)
            } else {
                unrecognizedCode = RootScannedQRCode(value: code)
            }
        }
        .sheet(item: $scannedPayload) { wrapper in
            ScannedProfileView(payload: wrapper.payload)
        }
        .sheet(item: $unrecognizedCode) { result in
            RootScannedCodeSheet(code: result.value)
                .presentationDetents([.medium])
        }
    }
}

private struct RootScannedQRCode: Identifiable {
    let id = UUID()
    let value: String
}

private struct RootScannedPayload: Identifiable {
    let id = UUID()
    let payload: SuperDexQRPayload
}

private struct RootScannedCodeSheet: View {
    let code: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(code)
                    .font(.gilroy(.regular, size: 14))
                    .monospaced()
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Scanned Code")
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
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
