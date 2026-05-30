//
//  DesignSystem.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI

// MARK: - Design System
enum TrackrDesign {
    
    // MARK: Colors
    enum Colors {
        static let background = Color(hex: "0A0A0F")
        static let surface = Color(hex: "111118")
        static let surfaceElevated = Color(hex: "1A1A24")
        static let surfaceHigh = Color(hex: "22222F")
        static let border = Color(white: 1, opacity: 0.06)
        static let borderMedium = Color(white: 1, opacity: 0.10)
        
        static let accent = Color(hex: "6B5CE7")
        static let accentLight = Color(hex: "8B7CF8")
        static let accentGlow = Color(hex: "6B5CE7").opacity(0.3)
        
        static let green = Color(hex: "34D399")
        static let greenDim = Color(hex: "34D399").opacity(0.15)
        static let red = Color(hex: "F87171")
        static let redDim = Color(hex: "F87171").opacity(0.15)
        static let orange = Color(hex: "FB923C")
        static let blue = Color(hex: "60A5FA")
        
        static let textPrimary = Color.white
        static let textSecondary = Color(white: 1, opacity: 0.55)
        static let textTertiary = Color(white: 1, opacity: 0.30)
    }
    
    // MARK: Typography
    enum Font {
        static func display(_ size: CGFloat, weight: SwiftUI.Font.Weight = .bold) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .rounded)
        }
        static func body(_ size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .default)
        }
        static func mono(_ size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .monospaced)
        }
    }
    
    // MARK: Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: Corner Radius
    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let pill: CGFloat = 100
    }
    
    // MARK: Animation
    enum Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.38, dampingFraction: 0.75)
        static let snappy = SwiftUI.Animation.spring(response: 0.28, dampingFraction: 0.82)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.25)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
