//
//  MyAccountDisclosureRow.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

enum BasicMenuRowStyle {
    case navigation
    case action
    case destructiveAction
    case info(trailing: String)
    
    var labelForegroundColor: Color {
        switch self {
        case .navigation: return .black
        case .action: return .accentColor
        case .destructiveAction: return .red
        case .info: return .black
        }
    }
    
    @ViewBuilder
    var trailingIcon: some View {
        switch self {
        case .navigation: Image("arrow-right-14").foregroundStyle(Color.accentColor)
        case .info(let trailing):
            Text(trailing)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.gray35)
        default: EmptyView()
        }
    }
}

struct BasicMenuRow: View {
    let label: String
    let hasDivider: Bool
    let style: BasicMenuRowStyle
    let subtitle: String?
    let action: () -> Void
    
    private var disabled: Bool {
        if case .info = style { return true }
        else { return false }
    }
    
    init(_ label: String, _ hasDivider: Bool = true, _ style: BasicMenuRowStyle = .navigation, _ subtitle: String? = nil, onTapped: @escaping () -> Void) {
        self.label = label
        self.hasDivider = hasDivider
        self.style = style
        self.subtitle = subtitle
        self.action = onTapped
    }
    
    init(_ label: String, _ style: BasicMenuRowStyle = .navigation, _ subtitle: String? = nil, onTapped: @escaping () -> Void) {
        self.label = label
        self.hasDivider = true
        self.style = style
        self.subtitle = subtitle
        self.action = onTapped
    }
    
    var body: some View {
        VStack(spacing: 0){
            Button(action: action) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(label)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(style.labelForegroundColor)
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.gray35)
                        }
                    }
                    Spacer()
                    style.trailingIcon
                }
                .padding(10)
            }
            .buttonStyle(SquareHighlightButtonStyle(cornerRadius: 12))
            .disabled(disabled)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            if hasDivider {
                HorizontalDivider()
            }
        }
        .padding(.top, 10)
    }
}
