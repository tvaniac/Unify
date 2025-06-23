import SwiftUI

struct RoundedTopCorners: Shape {
    var radius: CGFloat = 30.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY)) // bottom left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius)) // up left
        path.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.minY)) // top left corner
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY)) // top side
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius),
                          control: CGPoint(x: rect.maxX, y: rect.minY)) // top right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // down right
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // bottom side

        return path
    }
}
