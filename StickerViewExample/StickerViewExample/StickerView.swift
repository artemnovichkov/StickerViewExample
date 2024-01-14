//
//  Created by Artem Novichkov on 13.01.2024.
//

import SwiftUI

struct StickerView: View {

    @Binding var image: UIImage
    @Binding var sticker: UIImage?
    @State private var spoilerViewOpacity: Double = 0
    @State private var stickerScale: Double = 1

    private let animation: Animation = .easeOut(duration: 1)

    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .opacity(sticker == nil ? 1 : 0)
                .animation(animation, value: sticker)
                .overlay {
                    SpoilerView(isOn: true)
                        .opacity(spoilerViewOpacity)
                }
            if let sticker {
                Image(uiImage: sticker)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(stickerScale)
                    .onAppear {
                        withAnimation(animation) {
                            spoilerViewOpacity = 1
                            stickerScale = 1.1
                        } completion: {
                            withAnimation(.linear) {
                                spoilerViewOpacity = 0
                            }
                            withAnimation(animation) {
                                stickerScale = 1
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    StickerView(image: .constant(.cat), sticker: .constant(nil))
}
