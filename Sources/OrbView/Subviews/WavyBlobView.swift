import SwiftUI

struct WavyBlobView: View {
    @ObservedObject var animationDriver: OrbAnimationDriver
    @StateObject private var pointCache = WavyBlobPointCache()

    private let color: Color
    private let loopDuration: Double

    init(color: Color,
         loopDuration: Double = 1,
         animationDriver: OrbAnimationDriver) {
        self.color = color
        self.loopDuration = loopDuration
        self.animationDriver = animationDriver
    }

    var body: some View {
        Canvas { context, size in
            let angle = animationDriver.getWavyBlobAngle(loopDuration: loopDuration)
            let adjustedPoints = pointCache.getPoints(for: angle, size: size)

            var path = Path()
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) * 0.45

                // Start the path
                path.move(to: adjustedPoints[0])

                // Create smooth curves between points
                for i in 0 ..< adjustedPoints.count {
                    let next = (i + 1) % adjustedPoints.count

                    // Calculate the angle between points
                    let currentAngle = atan2(
                        adjustedPoints[i].y - center.y,
                        adjustedPoints[i].x - center.x
                    )
                    let nextAngle = atan2(
                        adjustedPoints[next].y - center.y,
                        adjustedPoints[next].x - center.x
                    )

                    // Create perpendicular handles
                    let handleLength = radius * 0.33

                    let control1 = CGPoint(
                        x: adjustedPoints[i].x + cos(currentAngle + .pi / 2) * handleLength,
                        y: adjustedPoints[i].y + sin(currentAngle + .pi / 2) * handleLength
                    )

                    let control2 = CGPoint(
                        x: adjustedPoints[next].x + cos(nextAngle - .pi / 2) * handleLength,
                        y: adjustedPoints[next].y + sin(nextAngle - .pi / 2) * handleLength
                    )

                    path.addCurve(
                        to: adjustedPoints[next],
                        control1: control1,
                        control2: control2
                    )
                }

                context.fill(path, with: .color(color))
            }
    }
}

#Preview {
    WavyBlobView(color: .purple, animationDriver: OrbAnimationDriver())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
}
