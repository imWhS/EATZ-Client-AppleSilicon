//
//  ColorExtensions.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/10/25.
//

import SwiftUI

extension Color {
    
    static let highlight = Color("F23F18")
    
}

extension Color {
    
    init(_ hex: String) {
        let scanner = Scanner(string: hex)
            _ = scanner.scanString("#")
            
            var rgb: UInt64 = 0
            scanner.scanHexInt64(&rgb)
            
            let r = Double((rgb >> 16) & 0xFF) / 255.0
            let g = Double((rgb >>  8) & 0xFF) / 255.0
            let b = Double((rgb >>  0) & 0xFF) / 255.0
            self.init(red: r, green: g, blue: b)
    }
    
}
