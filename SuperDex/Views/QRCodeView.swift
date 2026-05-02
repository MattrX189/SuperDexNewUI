//
//  QRCodeView.swift
//  HomeScreen
//
//  Created by Gaurang Pant on 15/04/26.
//

import SwiftUI

struct QRCodeView: View {
    @State private var viewModel = QRCodeViewModel()
    @State private var isScanning: Bool = false
    @State private var scannedPayload: ScannedPayload?
    @State private var unrecognizedCode: ScannedQRCode?
    @Environment(UserProfileViewModel.self) private var profileVM

    private var profile: UserProfileData { profileVM.profile }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: profile.theme.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Circle()
                    .fill(profile.theme.accentColor.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: -120, y: -200)

                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: 130, y: 200)

                VStack(spacing: 24) {
                    Spacer()

                    if profile.name.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "qrcode")
                                .font(.gilroy(.regular, size: 60))
                                .foregroundStyle(.white.opacity(0.3))

                            Text("No Profile Yet")
                                .font(.gilroy(.bold, size: 22))
                                .foregroundStyle(.white.opacity(0.7))

                            Text("Set up your profile to generate\na personal QR code.")
                                .font(.gilroy(.regular, size: 15))
                                .foregroundStyle(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        Text(profile.name)
                            .font(.gilroy(.bold, size: 28))
                            .foregroundStyle(.white)

                        if !profile.jobRole.isEmpty {
                            Text(profile.jobRole)
                                .font(.gilroy(.medium, size: 15))
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(.white.opacity(0.15))
                                .clipShape(Capsule())
                        }

                        if let qrImage = viewModel.generateQRCode(for: profile) {
                            VStack(spacing: 16) {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                            }
                            .padding(24)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                        }

                        Text("Scan with SuperDex to add me as a contact")
                            .font(.gilroy(.regular, size: 13))
                            .foregroundStyle(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("My QR Code")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isScanning = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.gilroy(.semiBold, size: 18))
                            .foregroundStyle(.white)
                    }
                }
            }
            .qrScanner(isScanning: $isScanning) { code in
                if let payload = SuperDexQRPayload.decode(from: code) {
                    scannedPayload = ScannedPayload(payload: payload)
                } else {
                    unrecognizedCode = ScannedQRCode(value: code)
                }
            }
            .sheet(item: $scannedPayload) { wrapper in
                ScannedProfileView(payload: wrapper.payload)
            }
            .sheet(item: $unrecognizedCode) { result in
                ScannedCodeSheet(code: result.value)
                    .presentationDetents([.medium])
            }
        }
    }
}

private struct ScannedQRCode: Identifiable {
    let id = UUID()
    let value: String
}

private struct ScannedPayload: Identifiable {
    let id = UUID()
    let payload: SuperDexQRPayload
}

private struct ScannedCodeSheet: View {
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
    QRCodeView()
        .environment(UserProfileViewModel())
}
