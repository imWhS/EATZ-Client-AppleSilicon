//
//  ErrorCurtain.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/7/25.
//

import SwiftUI

struct ErrorCurtain: View {
    let message: String?
    let onRetryTapped: (() -> Void)?
    
    init(_ message: String, onRetryTapped: (() -> Void)? = nil) {
        self.message = message
        self.onRetryTapped = onRetryTapped
    }
    
    init(onRetryTapped: (() -> Void)? = nil) {
        self.message = nil
        self.onRetryTapped = onRetryTapped
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image("closed-200")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(Color.init(hex: "DF8686"))
                    VStack(spacing: 4) {
                        Text("문제가 발생했어요.")
                            .font(.system(size: 17, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.gray35)
                        if let message = message {
                            Text(message)
                                .font(.system(size: 12, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.gray35)
                        }
                    }
                }
                if let onRetryTapped = onRetryTapped {
                    Button("다시 시도", action: onRetryTapped).buttonStyle(CapsuleButtonMediumStyle(status: .secondary))
                }
            }
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ErrorCurtain("헉...") {}
}
