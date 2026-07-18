//
//  ErrorCurtain.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/7/25.
//

import SwiftUI

struct ErrorCurtain: View {
    let message: String?
    let onRetry: (() -> Void)?
    
    init(_ message: String, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }
    
    init(onRetry: (() -> Void)? = nil) {
        self.message = nil
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                VStack(spacing: 8) {
                    Text("문제가 발생했어요.")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.init(hex: "8B8B8B"))
                    if let message = message {
                        Text(message)
                            .font(.system(size: 12, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.init(hex: "A1A1A1"))
                    }
                }
                if let onRetry = onRetry {
                    Button("다시 시도", action: onRetry).buttonStyle(SmallRoundedButtonStyle(type: .secondary))
                }
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}
