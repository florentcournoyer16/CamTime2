import SwiftUI

enum CamTimeStyle {

    static let backgroundGradient = LinearGradient(
        colors: [
            Color.pink.opacity(0.35),
            Color.pink.opacity(0.15),
            Color.white
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBackground = Color.white.opacity(0.9)

    static let accent = Color.pink
}
