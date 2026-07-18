//
//  BlockContextModifier.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/17/26.
//

import SwiftUI

struct BlockContextModifier: ViewModifier {
    @Binding var targetUser: UserEssential?
    var onSuccess: () -> Void
    
    @State private var presentLearnMore: Bool = false
    @State private var alert: UserBlockAlert?
    
    private var blockService = UserBlockService.shared
    
    func body(content: Content) -> some View {
        content
            .onChange(of: targetUser) { _, newTargetUser in
                self.presentAlert(newTargetUser)
            }
            .alert(
                alert?.title ?? "",
                isPresented: Binding(
                    get: { self.alert != nil },
                    set: { isPresented in
                        if !isPresented {
                            self.alert = nil
                            self.targetUser = nil }}),
                presenting: alert,
                actions: { $0.actions },
                message: { $0.message })
            .sheet(isPresented: $presentLearnMore) {
                UserBlockShowLearnMoreView()
            }
    }
    
    private func presentAlert(_ targetUser: UserEssential?) {
        if let targetUser = targetUser {
            alert = .confirmBlock(targetUser,
                blockAction: { self.block(targetUser) },
                showMoreAction: { self.presentLearnMore = true })
        }
    }
    
    private func block(_ targetUser: UserEssential) {
        blockService.block(for: targetUser.id) { result in
            switch result {
            case .success:
                self.alert = nil
                self.onSuccess()
            case .failure(let networkError): self.alert = .error(message: networkError.userMessage)
            }
        }
    }
}

enum UserBlockAlert {
    case confirmBlock(_ targetUser: UserEssential?, blockAction: () -> Void, showMoreAction: () -> Void)
    case error(message: String)
    
    var title: String {
        switch self {
        case .confirmBlock(let targetUser, _, _):
            var prefixLabel = ""
            if let username = targetUser?.username { prefixLabel += (username + " 님을 ") }
            else { prefixLabel += "사용자를 " }
            return prefixLabel + "차단할까요?"
        case .error: return "사용자 차단 실패"
        }
    }

    @ViewBuilder
    var message: some View {
        switch self {
        case .confirmBlock(let targetUser, _, _):
            if let username = targetUser?.username {
                Text("차단하면, \(username) 님이 작성한 콘텐츠를 포함한 활동이 더 이상 보이지 않아요.")
            } else {
                Text("차단하면, 사용자가 작성한 콘텐츠를 포함한 활동이 더 이상 보이지 않아요.")
            }
        case .error(let message): Text(message)
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .confirmBlock(_, let blockAction, let showMoreAction):
            Button("차단", role: .destructive, action: blockAction)
            Button("더 알아보기", action: showMoreAction)
            Button("취소", role: .cancel) {}
        case .error(_):
            Button("확인", role: .cancel) {}
        }
    }
}

extension View {
    func getBlockContext(targetUser: Binding<UserEssential?>, onSuccess: @escaping () -> Void) -> some View {
        self.modifier(
            BlockContextModifier(
                targetUser: targetUser,
                onSuccess: onSuccess))
    }
}
