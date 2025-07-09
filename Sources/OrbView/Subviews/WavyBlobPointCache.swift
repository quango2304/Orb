//
//  WavyBlobPointCache.swift
//  Orb
//
//  Created by Optimization on 2024-11-09.
//

import SwiftUI

/// Cache for pre-calculated wavy blob point variations to reduce CPU usage
class WavyBlobPointCache: ObservableObject {
    private var pointVariationsCache: [String: [CGPoint]] = [:]
    private let basePoints: [CGPoint]
    
    // Number of pre-calculated variations for smooth animation
    private let variationCount = 120 // 2 seconds at 60fps
    
    init() {
        // Initialize base points (same as original WavyBlobView)
        self.basePoints = (0..<6).map { index in
            let angle = (Double(index) / 6) * 2 * .pi
            return CGPoint(
                x: 0.5 + cos(angle) * 0.9,
                y: 0.5 + sin(angle) * 0.9
            )
        }
        
        preCalculateVariations()
    }
    
    private func preCalculateVariations() {
        // Pre-calculate point variations for different animation phases
        for variation in 0..<variationCount {
            let normalizedTime = Double(variation) / Double(variationCount)
            let angle = normalizedTime * 2 * .pi
            
            let adjustedPoints = basePoints.enumerated().map { index, point in
                let phaseOffset = Double(index) * .pi / 3
                let xOffset = sin(angle + phaseOffset) * 0.15
                let yOffset = cos(angle + phaseOffset) * 0.15
                return CGPoint(
                    x: point.x + xOffset,
                    y: point.y + yOffset
                )
            }
            
            pointVariationsCache["\(variation)"] = adjustedPoints
        }
    }
    
    /// Get pre-calculated points for a given animation angle
    func getPoints(for angle: Double, size: CGSize) -> [CGPoint] {
        // Normalize angle to 0-2π range
        let normalizedAngle = angle.remainder(dividingBy: 2 * .pi)
        let positiveAngle = normalizedAngle < 0 ? normalizedAngle + 2 * .pi : normalizedAngle
        
        // Map to variation index
        let variationIndex = Int((positiveAngle / (2 * .pi)) * Double(variationCount)) % variationCount
        
        guard let cachedPoints = pointVariationsCache["\(variationIndex)"] else {
            // Fallback to real-time calculation if cache miss
            return calculatePointsRealTime(angle: angle)
        }
        
        // Transform cached points to actual size
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) * 0.45
        
        return cachedPoints.map { point in
            CGPoint(
                x: (point.x - 0.5) * radius + center.x,
                y: (point.y - 0.5) * radius + center.y
            )
        }
    }
    
    private func calculatePointsRealTime(angle: Double) -> [CGPoint] {
        // Fallback real-time calculation (same as original logic)
        return basePoints.enumerated().map { index, point in
            let phaseOffset = Double(index) * .pi / 3
            let xOffset = sin(angle + phaseOffset) * 0.15
            let yOffset = cos(angle + phaseOffset) * 0.15
            return CGPoint(
                x: point.x + xOffset,
                y: point.y + yOffset
            )
        }
    }
    
    /// Get cache statistics for debugging
    var cacheStats: Int {
        return pointVariationsCache.count
    }
}
