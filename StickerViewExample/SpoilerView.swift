//
//  Created by Artem Novichkov on 13.01.2024.
//

import SwiftUI

final class EmitterView: UIView {

    override class var layerClass: AnyClass {
        CAEmitterLayer.self
    }

    override var layer: CAEmitterLayer {
        super.layer as! CAEmitterLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.emitterPosition = .init(x: bounds.size.width / 2,
                                      y: bounds.size.height / 2)
        layer.emitterSize = bounds.size
    }
}

/// Based on [InvisibleInkDustNode.swift](https://github.com/TelegramMessenger/Telegram-iOS/blob/930d1fcc46e39830e6d590986a6a838c3ff49e27/submodules/InvisibleInkDustNode/Sources/InvisibleInkDustNode.swift#L97-L109)
struct SpoilerView: UIViewRepresentable {

    var isOn: Bool

    func makeUIView(context: Context) -> EmitterView {
        let emitterView = EmitterView()

        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "textSpeckle_Normal")?.cgImage
        emitterCell.color = UIColor.label.cgColor
        emitterCell.contentsScale = 1.8
        emitterCell.emissionRange = .pi * 2
        emitterCell.lifetime = 1
        emitterCell.scale = 0.5
        emitterCell.velocityRange = 20
        emitterCell.alphaRange = 1
        emitterCell.birthRate = 4000

        emitterView.layer.emitterShape = .rectangle
        emitterView.layer.emitterCells = [emitterCell]

        return emitterView
    }

    func updateUIView(_ uiView: EmitterView, context: Context) {
        if isOn {
            uiView.layer.beginTime = CACurrentMediaTime()
        }
        uiView.layer.birthRate = isOn ? 1 : 0
    }
}
