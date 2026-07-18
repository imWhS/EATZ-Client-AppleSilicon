//
//  BasicCurtain.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/19/25.
//

import SwiftUI

struct Curtain<Header: View, Footer: View>: View {
    var title: String
    var description: String?
    
    let actionTitle: String?
    let action: (() -> Void)?
    
    @ViewBuilder let header: () -> Header
    @ViewBuilder let footer: () -> Footer
    
    init(
        title: String,
        description: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer) {
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
        self.header = header
        self.footer = footer
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                header()
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.init(hex: "8B8B8B"))
                    if let description = description {
                        Text(description)
                            .font(.system(size: 12, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.init(hex: "A1A1A1"))
                    }
                }
                if let action = action {
                    Button(actionTitle ?? "다시 시도", action: action)
                        .buttonStyle(SmallRoundedButtonStyle(type: .secondary))
                }
                footer()
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}

extension Curtain where Footer == EmptyView {
    init(title: String,
         description: String? = nil,
         actionTitle: String? = nil,
         action: (() -> Void)? = nil,
         @ViewBuilder header: @escaping () -> Header
    ) {
        self.init(
            title: title,
            description: description,
            actionTitle: actionTitle,
            action: action,
            header: header,
            footer: { EmptyView() })
    }
}

extension Curtain where Header == EmptyView {
    init(title: String,
         description: String? = nil,
         actionTitle: String? = nil,
         action: (() -> Void)? = nil,
         @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(
            title: title,
            description: description,
            actionTitle: actionTitle,
            action: action,
            header: { EmptyView() },
            footer: footer)
    }
}

extension Curtain where Header == EmptyView, Footer == EmptyView {
    init(title: String,
         description: String? = nil,
         actionTitle: String? = nil,
         action: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            description: description,
            actionTitle: actionTitle,
            action: action,
            header: { EmptyView() },
            footer: { EmptyView() })
    }
}

