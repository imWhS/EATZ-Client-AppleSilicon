//
//  VerticalLabeledValueView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 2/20/26.
//

import SwiftUI

enum VerticalLabeledValueStyle {
    case primary
    case secondary
    
    var font: Font {
        switch self {
        case .primary: .system(size: 17, weight: .semibold)
        case .secondary: .system(size: 17, weight: .medium)
        }
    }
}

struct VerticalLabeledValueView: View {
    let label: String
    let value: String
    let style: VerticalLabeledValueStyle
    
    init(label: String, value: String, style: VerticalLabeledValueStyle = .primary) {
        self.label = label
        self.value = value
        self.style = style
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: "BCBCBC"))
                Text(value)
                    .font(style.font)
                    .foregroundStyle(.black)
            }
        }
    }
}
