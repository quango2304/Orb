//
//  OrbAnimationDriver.swift
//  Orb
//
//  Created by Optimization on 2024-11-09.
//

import SwiftUI
import Combine

/// Central animation driver that manages all orb animations from a single source
/// This reduces CPU usage by consolidating multiple independent animations
class OrbAnimationDriver: ObservableObject {
    @Published private(set) var animationTime: Double = 0
    
    private var timer: Timer?
    private let startTime = Date()
    
    // Cached rotation values for different speeds and directions
    @Published private(set) var rotations: [String: Double] = [:]
    
    init() {
        startAnimations()
    }
    
    deinit {
        stopAnimations()
    }
    
    private func startAnimations() {
        // Use 60fps timer but batch all calculations
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateAnimations()
            }
        }
    }
    
    private func stopAnimations() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateAnimations() {
        let currentTime = Date().timeIntervalSince(startTime)
        animationTime = currentTime
        
        // Pre-calculate common rotation values to avoid redundant calculations
        updateRotationCache(for: currentTime)
    }
    
    private func updateRotationCache(for time: Double) {
        // Cache rotations for common speed multipliers used in the orb
        let speedMultipliers: [Double] = [0.25, 0.75, 1.5, 2.3, 3.0]
        
        for multiplier in speedMultipliers {
            let clockwiseKey = "cw_\(multiplier)"
            let counterClockwiseKey = "ccw_\(multiplier)"
            
            // Calculate rotation based on time and speed
            let baseRotation = (time * multiplier * 60) // 60 is base speed
            
            rotations[clockwiseKey] = baseRotation.truncatingRemainder(dividingBy: 360)
            rotations[counterClockwiseKey] = (-baseRotation).truncatingRemainder(dividingBy: 360)
        }
    }
    
    /// Get rotation value for a specific speed and direction
    func getRotation(speed: Double, direction: RotationDirection, baseSpeed: Double = 60) -> Double {
        let multiplier = speed / baseSpeed
        let key = direction == .clockwise ? "cw_\(multiplier)" : "ccw_\(multiplier)"
        
        // If we have a cached value, use it
        if let cachedRotation = rotations[key] {
            return cachedRotation
        }
        
        // Otherwise calculate on demand
        let baseRotation = (animationTime * multiplier * baseSpeed)
        return direction == .clockwise ? 
            baseRotation.truncatingRemainder(dividingBy: 360) :
            (-baseRotation).truncatingRemainder(dividingBy: 360)
    }
    
    /// Get animation time for wavy blob calculations
    func getWavyBlobAngle(loopDuration: Double) -> Double {
        return (animationTime.remainder(dividingBy: loopDuration) / loopDuration) * 2 * .pi
    }
}
