//
//  Color+Extensions.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/10/25.
//

import SwiftUI

extension Color {
    static let auth = Color("auth")
    static let rating = Color("Colors/rating")
    static let backgroundPrimary = Color("Colors/backgroundPrimary")
    static let buttonSecondary = Color("Colors/buttonSecondary")
    static let gray60 = Color("Colors/gray60")
    static let gray50 = Color("Colors/gray50")
    static let gray35 = Color("Colors/gray35")
    static let gray25 = Color("Colors/gray25")
    static let gray20 = Color("Colors/gray20")
    static let gray15 = Color("Colors/gray15")
    static let gray8 = Color("Colors/gray8")
    static let gray4 = Color("Colors/gray4")
    static let gray2 = Color("Colors/gray2")
}

extension Color {
    /// Hex 색상 코드로 `Color` 인스턴스를 만듭니다.
    init(hex: String, opacity: Double = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "유효하지 않은 hex 색상 코드예요.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double((rgbValue & 0x0000FF) >> 0) / 255.0
        self.init(red: r, green: g, blue: b, opacity: opacity)
    }
}
