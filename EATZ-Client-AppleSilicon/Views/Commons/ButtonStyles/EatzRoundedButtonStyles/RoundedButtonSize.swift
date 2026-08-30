//
//  RoundedButtonSize.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/29/26.
//

import SwiftUI

enum RoundedButtonSize {
    case large
    case medium
    case mediumSquared
    
    var font: Font {
        switch self {
        case .large: return .system(size: 17, weight: .semibold)
        case .medium: return .system(size: 14, weight: .semibold)
        case .mediumSquared: return .subheadline.weight(.semibold)
        }
    }
       
    var horizontalPadding: CGFloat {
        switch self {
        case .large: return 18
        case .medium: return 14
        case .mediumSquared: return 7
        }
    }
       
    var verticalPadding: CGFloat {
        switch self {
        case .large: return 10
        case .medium: return 7
        case .mediumSquared: return 7
        }
    }
    
    var cornerRadius: CGFloat {
        return 14
    }
}
