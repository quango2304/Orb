//
//  ParticleTextureCache.swift
//  Orb
//
//  Created by Optimization on 2024-11-09.
//

import SpriteKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Static cache for particle textures to avoid recreating them repeatedly
class ParticleTextureCache {
    nonisolated(unsafe) static let shared = ParticleTextureCache()

    private var textureCache: [String: SKTexture] = [:]
    
    private init() {
        // Pre-generate common texture sizes
        preGenerateCommonTextures()
    }
    
    private func preGenerateCommonTextures() {
        let commonSizes: [CGSize] = [
            CGSize(width: 4, height: 4),
            CGSize(width: 8, height: 8),
            CGSize(width: 12, height: 12),
            CGSize(width: 16, height: 16)
        ]
        
        for size in commonSizes {
            _ = getTexture(size: size)
        }
    }
    
    /// Get cached texture or create and cache it
    func getTexture(size: CGSize) -> SKTexture {
        let key = "\(Int(size.width))x\(Int(size.height))"
        
        if let cachedTexture = textureCache[key] {
            return cachedTexture
        }
        
        // Create new texture
        let texture = createParticleTexture(size: size)
        textureCache[key] = texture
        
        return texture
    }
    
    private func createParticleTexture(size: CGSize) -> SKTexture {
        #if canImport(UIKit)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            // Create a smooth circular gradient for better visual quality
            let rect = CGRect(origin: .zero, size: size)
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2

            // Create radial gradient from white center to transparent edge
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(0.8).cgColor,
                UIColor.white.withAlphaComponent(0.4).cgColor,
                UIColor.clear.cgColor
            ]
            let locations: [CGFloat] = [0.0, 0.3, 0.7, 1.0]

            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) else {
                // Fallback to simple circle
                UIColor.white.setFill()
                let circlePath = UIBezierPath(ovalIn: rect)
                circlePath.fill()
                return
            }

            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 0,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }

        return SKTexture(image: image)
        #else
        // macOS fallback using NSImage
        let image = NSImage(size: size)
        image.lockFocus()

        let rect = CGRect(origin: .zero, size: size)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2

        // Simple white circle for macOS
        NSColor.white.setFill()
        let circlePath = NSBezierPath(ovalIn: rect)
        circlePath.fill()

        image.unlockFocus()
        return SKTexture(image: image)
        #endif
    }
    
    /// Clear cache to free memory
    func clearCache() {
        textureCache.removeAll()
    }
    
    /// Get cache statistics for debugging
    var cacheStats: Int {
        return textureCache.count
    }
}
