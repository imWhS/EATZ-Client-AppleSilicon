//
//  UIColor+Extensions.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 3/24/26.
//

import UIKit

extension UIColor {
    /// Hex 색상 코드로 `UIColor` 인스턴스를 만듭니다.
    convenience init(hex: String, alpha: CGFloat = 1.0) {
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
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
