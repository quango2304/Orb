//
//  ViewCache.swift
//  Orb
//
//  Created by Optimization on 2024-11-09.
//

import SwiftUI

/// Cache for expensive view calculations and results
class ViewCache: ObservableObject {
    private var gradientCache: [String: LinearGradient] = [:]
    private var shadowModifierCache: [String: RealisticShadowModifier] = [:]
    
    /// Get cached linear gradient or create and cache it
    func getLinearGradient(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint) -> LinearGradient {
        let key = "\(colors.map { $0.description }.joined())_\(startPoint)_\(endPoint)"
        
        if let cached = gradientCache[key] {
            return cached
        }
        
        let gradient = LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
        gradientCache[key] = gradient
        return gradient
    }
    
    /// Get cached shadow modifier or create and cache it
    func getShadowModifier(colors: [Color], radius: CGFloat) -> RealisticShadowModifier {
        let key = "\(colors.map { $0.description }.joined())_\(Int(radius * 100))"
        
        if let cached = shadowModifierCache[key] {
            return cached
        }
        
        let modifier = RealisticShadowModifier(colors: colors, radius: radius)
        shadowModifierCache[key] = modifier
        return modifier
    }
    
    /// Clear cache to free memory
    func clearCache() {
        gradientCache.removeAll()
        shadowModifierCache.removeAll()
    }
    
    /// Get cache statistics for debugging
    var cacheStats: (gradients: Int, shadows: Int) {
        return (gradientCache.count, shadowModifierCache.count)
    }
}
