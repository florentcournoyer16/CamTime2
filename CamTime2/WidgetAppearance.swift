import SwiftUI

// MARK: - Appearance model

struct CamWidgetAppearance: Codable {
    let backgroundTint: CodableColor
    let accentColor: CodableColor
    let fontStyle: FontStyle
}


enum FontStyle: String, Codable, CaseIterable {
    case regular
    case rounded
    case serif
}

// MARK: - Codable Color

struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(_ color: Color) {
        let ui = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)

        red = r
        green = g
        blue = b
        alpha = a
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - Defaults

extension CamWidgetAppearance {
    static let `default` = CamWidgetAppearance(
        backgroundTint: CodableColor(.pink.opacity(0.2)),
        accentColor: CodableColor(.black.opacity(0.8)),
        fontStyle: .rounded
    )
}
