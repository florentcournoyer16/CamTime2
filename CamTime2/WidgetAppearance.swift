import Foundation

struct CamWidgetAppearance: Codable {
    let backgroundStyle: BackgroundStyle
    let accentColor: String
    let fontStyle: FontStyle
}

enum BackgroundStyle: String, Codable {
    case system, light, dark
}

enum FontStyle: String, Codable {
    case regular, rounded, serif
}

