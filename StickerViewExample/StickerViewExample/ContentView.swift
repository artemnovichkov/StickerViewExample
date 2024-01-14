//
//  Created by Artem Novichkov on 13.01.2024.
//

import SwiftUI
import PhotosUI
import Vision
import CoreImage.CIFilterBuiltins

struct ContentView: View {

    @State private var image = UIImage.cat
    @State private var sticker: UIImage?
    @State private var isLoading: Bool = false

    private var processingQueue = DispatchQueue(label: "ProcessingQueue")

    var body: some View {
        VStack(spacing: 16) {
            StickerView(image: $image, sticker: $sticker)
            Button(action: { createSticker() }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Text("Create a sticker")
                }
            }
        }
        .padding()
    }

    // MARK: - Private

    private func createSticker() {
        if isLoading {
            return
        }
        guard let inputImage = CIImage(image: image) else {
            print("Failed to create CIImage")
            return
        }
        isLoading = true
        processingQueue.async {
            guard let maskImage = subjectMaskImage(from: inputImage) else {
                print("Failed to create mask image")
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            let outputImage = apply(mask: maskImage, to: inputImage)
            let cgImage = render(ciImage: outputImage)
            let image = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                isLoading = false
                sticker = image
            }
        }
    }

    private func subjectMaskImage(from inputImage: CIImage) -> CIImage? {
        let handler = VNImageRequestHandler(ciImage: inputImage)
        let request = VNGenerateForegroundInstanceMaskRequest()
        do {
            try handler.perform([request])
        } catch {
            print(error)
            return nil
        }
        guard let result = request.results?.first else {
            print("No observations found")
            return nil
        }
        do {
            let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            return CIImage(cvPixelBuffer: maskPixelBuffer)
        } catch {
            print(error)
            return nil
        }
    }

    private func apply(mask: CIImage, to image: CIImage) -> CIImage {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = image
        filter.maskImage = mask
        filter.backgroundImage = CIImage.empty()
        return filter.outputImage!
    }

    private func render(ciImage: CIImage) -> CGImage {
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {
            fatalError("Failed to render CIImage.")
        }
        return cgImage
    }
}

#Preview {
    ContentView()
}
