//
//  BackgroundView.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//

import SwiftUI

enum RotationDirection {
    case clockwise
    case counterClockwise

    var multiplier: Double {
        switch self {
        case .clockwise: return 1
        case .counterClockwise: return -1
        }
    }
}

struct RotatingGlowView: View {
    @ObservedObject var animationDriver: OrbAnimationDriver
    @ObservedObject var geometryCache: GeometryCache

    private let color: Color
    private let rotationSpeed: Double
    private let direction: RotationDirection

    init(color: Color,
         rotationSpeed: Double = 30,
         direction: RotationDirection,
         animationDriver: OrbAnimationDriver,
         geometryCache: GeometryCache)
    {
        self.color = color
        self.rotationSpeed = rotationSpeed
        self.direction = direction
        self.animationDriver = animationDriver
        self.geometryCache = geometryCache
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometryCache.getSize(from: geometry)
            let blurRadius = geometryCache.getBlurRadius(size: size, multiplier: 0.16)
            let rotation = animationDriver.getRotation(speed: rotationSpeed, direction: direction)

            Circle()
                .fill(color)
                .mask {
                    ZStack {
                        Circle()
                            .frame(width: size, height: size)
                            .blur(radius: blurRadius)
                        Circle()
                            .frame(width: size * 1.31, height: size * 1.31)
                            .offset(y: size * 0.31)
                            .blur(radius: blurRadius)
                            .blendMode(.destinationOut)
                    }
                }
                .rotationEffect(.degrees(rotation))
        }
    }
}

#Preview {
    RotatingGlowView(color: .purple,
                   rotationSpeed: 30,
                   direction: .counterClockwise,
                   animationDriver: OrbAnimationDriver(),
                   geometryCache: GeometryCache())
        .frame(width: 128, height: 128)
}
