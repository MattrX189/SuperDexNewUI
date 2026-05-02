//
//  QRCodeViewModel.swift
//  HomeScreen
//

import SwiftUI
import CoreImage.CIFilterBuiltins

@Observable
final class QRCodeViewModel {
    func generateQRCode(forText text: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        guard let data = text.data(using: .utf8) else { return nil }
        filter.message = data
        filter.correctionLevel = "H"
        guard let ciImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = ciImage.transformed(by: transform)
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    func generateQRCode(for profile: ProfileCard) -> UIImage? {
        guard let text = SuperDexQRPayload(profile: profile).encodedString() else { return nil }
        return generateQRCode(forText: text)
    }

    func generateQRCode(for profile: UserProfileData) -> UIImage? {
        generateQRCode(for: profile.asProfileCard)
    }
}
