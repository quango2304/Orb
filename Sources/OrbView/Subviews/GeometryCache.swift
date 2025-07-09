//
//  GeometryCache.swift
//  Orb
//
//  Created by Optimization on 2024-11-09.
//

import SwiftUI

/// Cache for expensive geometry calculations to reduce CPU usage
class GeometryCache: ObservableObject {
    private var sizeCache: [String: CGFloat] = [:]
    private var blurRadiusCache: [String: CGFloat] = [:]
    private var paddingCache: [String: CGFloat] = [:]
    private var offsetCache: [String: CGSize] = [:]
    
    // Cache tolerance for floating point comparisons
    private let tolerance: CGFloat = 0.1
    
    /// Get cached size or calculate and cache it
    func getSize(from geometry: GeometryProxy) -> CGFloat {
        let width = geometry.size.width
        let height = geometry.size.height
        let key = "\(Int(width))x\(Int(height))"
        
        if let cached = sizeCache[key] {
            return cached
        }
        
        let size = min(width, height)
        sizeCache[key] = size
        return size
    }
    
    /// Get cached blur radius for a given size and multiplier
    func getBlurRadius(size: CGFloat, multiplier: CGFloat) -> CGFloat {
        let key = "\(Int(size))_\(Int(multiplier * 1000))"
        
        if let cached = blurRadiusCache[key] {
            return cached
        }
        
        let radius = size * multiplier
        blurRadiusCache[key] = radius
        return radius
    }
    
    /// Get cached padding for a given size and multiplier
    func getPadding(size: CGFloat, multiplier: CGFloat) -> CGFloat {
        let key = "\(Int(size))_\(Int(multiplier * 1000))"
        
        if let cached = paddingCache[key] {
            return cached
        }
        
        let padding = size * multiplier
        paddingCache[key] = padding
        return padding
    }
    
    /// Get cached offset for wavy blob positioning
    func getWavyBlobOffset(size: CGFloat, multiplier: CGFloat, isVertical: Bool = true) -> CGSize {
        let key = "\(Int(size))_\(Int(multiplier * 1000))_\(isVertical)"
        
        if let cached = offsetCache[key] {
            return cached
        }
        
        let offset = isVertical ? 
            CGSize(width: 0, height: size * multiplier) :
            CGSize(width: size * multiplier, height: 0)
        
        offsetCache[key] = offset
        return offset
    }
    
    /// Clear cache when memory pressure is high
    func clearCache() {
        sizeCache.removeAll()
        blurRadiusCache.removeAll()
        paddingCache.removeAll()
        offsetCache.removeAll()
    }
    
    /// Get cache statistics for debugging
    var cacheStats: (sizes: Int, blurs: Int, paddings: Int, offsets: Int) {
        return (sizeCache.count, blurRadiusCache.count, paddingCache.count, offsetCache.count)
    }
}
