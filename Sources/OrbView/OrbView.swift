//
//  OrbView.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//
import SwiftUI

public struct OrbView: View {
    private let config: OrbConfiguration
    @StateObject private var animationDriver = OrbAnimationDriver()
    @StateObject private var geometryCache = GeometryCache()
    @StateObject private var viewCache = ViewCache()

    public init(configuration: OrbConfiguration = OrbConfiguration()) {
        self.config = configuration
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = geometryCache.getSize(from: geometry)

            ZStack {
                // Base gradient background layer
                if config.showBackground {
                    background
                }

                // Creates depth with rotating glow effects
                baseDepthGlows(size: size)

                // Adds organic movement with flowing blob shapes
                if config.showWavyBlobs {
                    wavyBlob(size: size)
                    wavyBlobTwo(size: size)
                }

                // Adds bright, energetic core glow animations
                if config.showGlowEffects {
                    coreGlowEffects(size: size)
                }

                // Overlays floating particle effects for additional dynamism
                if config.showParticles {
                    particleView
                        .frame(maxWidth: size, maxHeight: size)
                }
            }
            // Orb outline for depth
            .overlay {
                realisticInnerGlows
            }
            // Masking out all the effects so it forms a perfect circle
            .mask {
                Circle()
            }
            .aspectRatio(1, contentMode: .fit)
            // Adding realistic, layered shadows so its brighter near the core, and softer as it grows outwards
            .modifier(
                viewCache.getShadowModifier(
                    colors: config.showShadow ? config.backgroundColors : [.clear],
                    radius: geometryCache.getBlurRadius(size: size, multiplier: 0.08)
                )
            )
        }
        .onAppear {
            animationDriver.objectWillChange.send()
        }
    }

    private var background: some View {
        viewCache.getLinearGradient(colors: config.backgroundColors,
                                  startPoint: .bottom,
                                  endPoint: .top)
    }

    private var orbOutlineColor: LinearGradient {
        viewCache.getLinearGradient(colors: [.white, .clear],
                                  startPoint: .bottom,
                                  endPoint: .top)
    }
    
    private var particleView: some View {
        // Added multiple particle effects since the blurring amounts are different
        ZStack {
            ParticlesView(
                color: config.particleColor,
                speedRange: 10...20,
                sizeRange: 0.5...1,
                particleCount: 10,
                opacityRange: 0...0.3
            )
            .blur(radius: 1)
            
            ParticlesView(
                color: config.particleColor,
                speedRange: 20...30,
                sizeRange: 0.2...1,
                particleCount: 10,
                opacityRange: 0.3...0.8
            )
        }
        .blendMode(.plusLighter)
    }

    private func wavyBlob(size: CGFloat) -> some View {
        RotatingGlowView(color: .white.opacity(0.75),
                       rotationSpeed: config.speed * 1.5,
                       direction: .clockwise,
                       animationDriver: animationDriver,
                       geometryCache: geometryCache)
            .mask {
                WavyBlobView(color: .white,
                           loopDuration: 60 / config.speed * 1.75,
                           animationDriver: animationDriver)
                    .frame(maxWidth: size * 1.875)
                    .offset(geometryCache.getWavyBlobOffset(size: size, multiplier: 0.31))
            }
            .blur(radius: 1)
            .blendMode(.plusLighter)
    }

    private func wavyBlobTwo(size: CGFloat) -> some View {
        RotatingGlowView(color: .white,
                       rotationSpeed: config.speed * 0.75,
                       direction: .counterClockwise,
                       animationDriver: animationDriver,
                       geometryCache: geometryCache)
            .mask {
                WavyBlobView(color: .white,
                           loopDuration: 60 / config.speed * 2.25,
                           animationDriver: animationDriver)
                    .frame(maxWidth: size * 1.25)
                    .rotationEffect(.degrees(90))
                    .offset(geometryCache.getWavyBlobOffset(size: size, multiplier: -0.31))
            }
            .opacity(0.5)
            .blur(radius: 1)
            .blendMode(.plusLighter)
    }

    private func coreGlowEffects(size: CGFloat) -> some View {
        ZStack {
            RotatingGlowView(color: config.glowColor,
                          rotationSpeed: config.speed * 3,
                          direction: .clockwise,
                          animationDriver: animationDriver,
                          geometryCache: geometryCache)
                .blur(radius: geometryCache.getBlurRadius(size: size, multiplier: 0.08))
                .opacity(config.coreGlowIntensity)

            RotatingGlowView(color: config.glowColor,
                          rotationSpeed: config.speed * 2.3,
                          direction: .clockwise,
                          animationDriver: animationDriver,
                          geometryCache: geometryCache)
                .blur(radius: geometryCache.getBlurRadius(size: size, multiplier: 0.06))
                .opacity(config.coreGlowIntensity)
                .blendMode(.plusLighter)
        }
        .padding(geometryCache.getPadding(size: size, multiplier: 0.08))
    }

    // New combined function replacing outerGlow and outerRing
    private func baseDepthGlows(size: CGFloat) -> some View {
        ZStack {
            // Outer glow (previously outerGlow function)
            RotatingGlowView(color: config.glowColor,
                          rotationSpeed: config.speed * 0.75,
                          direction: .counterClockwise,
                          animationDriver: animationDriver,
                          geometryCache: geometryCache)
                .padding(geometryCache.getPadding(size: size, multiplier: 0.03))
                .blur(radius: geometryCache.getBlurRadius(size: size, multiplier: 0.06))
                .rotationEffect(.degrees(180))
                .blendMode(.destinationOver)

            // Outer ring (previously outerRing function)
            RotatingGlowView(color: config.glowColor.opacity(0.5),
                          rotationSpeed: config.speed * 0.25,
                          direction: .clockwise,
                          animationDriver: animationDriver,
                          geometryCache: geometryCache)
                .frame(maxWidth: size * 0.94)
                .rotationEffect(.degrees(180))
                .padding(8)
                .blur(radius: geometryCache.getBlurRadius(size: size, multiplier: 0.032))
        }
    }

    private var realisticInnerGlows: some View {
        ZStack {
            // Outer stroke with heavy blur
            Circle()
                .stroke(orbOutlineColor, lineWidth: 8)
                .blur(radius: 32)
                .blendMode(.plusLighter)

            // Inner stroke with light blur
            Circle()
                .stroke(orbOutlineColor, lineWidth: 4)
                .blur(radius: 12)
                .blendMode(.plusLighter)
            
            Circle()
                .stroke(orbOutlineColor, lineWidth: 1)
                .blur(radius: 4)
                .blendMode(.plusLighter)
        }
        .padding(1)
    }
}

#Preview {
    let config = OrbConfiguration()
    OrbView(configuration: config)
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 120)
}
