//
//  BasicMenuRow.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

struct BasicMenuRow: View {
    let label: String
    let hasDivider: Bool
    let type: BasicMenuRowType
    let subtitle: String?
    let action: () -> Void
    
    private var isDisabled: Bool {
        switch type {
        case .info: return true
        default: return false
        }
    }
    
    init(_ label: String, _ hasDivider: Bool = true, _ style: BasicMenuRowType = .navigation, _ subtitle: String? = nil, onTapped: @escaping () -> Void) {
        self.label = label
        self.hasDivider = hasDivider
        self.type = style
        self.subtitle = subtitle
        self.action = onTapped
    }
    
    init(_ label: String, _ style: BasicMenuRowType = .navigation, _ subtitle: String? = nil, onTapped: @escaping () -> Void) {
        self.label = label
        self.hasDivider = true
        self.type = style
        self.subtitle = subtitle
        self.action = onTapped
    }
    
    var body: some View {
        VStack(spacing: 0){
            Group {
                switch type {
                case .info, .id: row
                default:
                    Button(action: {
                        if case .id = type { return }
                        action()
                    }) {
                        row
                    }
                    .buttonStyle(SquareHighlightButtonStyle(cornerRadius: 14))
                    .disabled(isDisabled)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            if hasDivider {
                HorizontalDivider()
            }
        }
        .padding(.top, 10)
    }
    
    private var row: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(type.labelForegroundColor)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.gray35)
                }
            }
            Spacer()
            type.trailingIcon
        }
        .padding(10)
    }
}

enum BasicMenuRowType {
    case navigation
    case externalLink
    case action
    case destructiveAction
    case info(trailing: String)
    case id(trailing: String)
    
    var labelForegroundColor: Color {
        switch self {
        case .navigation: return .black
        case .externalLink: return .accentColor
        case .action: return .accentColor
        case .destructiveAction: return .red
        case .info: return .black
        case .id: return .black
        }
    }
    
    @ViewBuilder
    var trailingIcon: some View {
        switch self {
        case .navigation: Image("arrow-right-14").foregroundStyle(Color.accentColor)
        case .externalLink: Image("external-link-14").foregroundStyle(Color.accentColor)
        case .info(let trailing):
            Text(trailing)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.gray35)
        case .id(let trailing):
            Text(trailing)
                .font(.system(size: 17, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.gray35)
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = trailing
                    } label: {
                        Label("복사하기", systemImage: "doc.on.doc")
                    }
                }
        default: EmptyView()
        }
    }
}
