//
//  UserBlocklistMemberView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/26.
//

import SwiftUI

struct DeleteAccountMemberView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject var authManager: AuthManager 
//    
//    private let userItemHorizontalPadding: CGFloat = 20
//    private let profileImageSize: CGFloat = 40
//    private let userItemProfileImageLabelSpacing: CGFloat = 12
//    private let userItemVerticalPadding: CGFloat = 16
    
    var body: some View {
        Group {
            switch authManager.state {
            case .unknown: LoadingCurtain(title: "인증 상태를 확인하고 있어요...")
            case .unauthorized: CommonUnauthorizedStateView()
            case .authenticated(let user): contentView.id(user.id)
            }
        }
        .background(Color.backgroundPrimary.ignoresSafeArea(edges: [.top, .bottom]))
        .navigationTitle("계정 삭제")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            titleToolbarItem
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 48)
                    VStack(spacing: 8) {
                        Text("계정 삭제")
                            .font(.system(size: 30, weight: .bold))
                        Text("미리 알아두어야 할 정보")
                            .font(.system(size: 17, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.gray35)
                    }
                }
                .padding(.vertical, 32)
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 20) {
                        warningRow("계정을 삭제하면, EATZ의 회원에서 탈퇴하게 돼요.")
                        warningRow("삭제된 계정은 복구할 수 없어요.")
                        warningRow("삭제된 계정에 사용한 이메일 주소는 삭제 시점에서부터 30일 동안 EATZ 계정을 만들 때 사용할 수 없어요. 30일 동안 탈퇴한 이메일 주소를 이용한 가입이 제한돼요.")
                        warningRow("레시피, 댓글, 평가 등의 콘텐츠를 포함한 모든 활동은 유지돼요.")
                        warningRow("관련 법령 준수 및 부정 가입 방지를 위해 계정 정보가 일정 기간 보관된 후 파기될 수 있어요.")
                    }
                    HorizontalDivider(padding: 20)
                    Text("계속 진행하면, 위 내용을 이해한 후 계정을 삭제하는 것으로 간주합니다.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.gray35)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 20)
                }
                Button(action: {
                    router.push(.deleteAccountDetail)
                }) {
                    HStack {
                        Text("계속")
                            .font(.system(size: 17, weight: .semibold))
                            .fontWeight(.semibold)
                        Image("arrow-right-14")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CapsuleLargeButtonStyle(appearance: .secondary))
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
        }
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("회원 탈퇴")
                .font(.headline)
                .opacity(0)
        }
    }
    
    private func warningRow(_ text: String) -> some View {
        VStack(spacing: 20) {
            HorizontalDivider()
            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
        }
    }
}

enum DeleteAccountMemberAlert {
    case confirmDelete(username: String, confirmAction: () -> Void)
    case deleteCompleted(confirmAction: () -> Void)
    case sessionExpired
    case error(message: String)
    
    var title: String {
        switch self {
        case .confirmDelete: "회원 탈퇴 최종 확인"
        case .deleteCompleted: "회원 탈퇴 완료"
        case .sessionExpired: "세션 만료"
        case .error: "오류"
        }
    }
    
    @ViewBuilder
    var actions: some View{
        switch self {
        case .confirmDelete(_, let confirmAction):
            Button("취소") {}
            Button("회원 탈퇴", action: confirmAction);
        case .deleteCompleted(let confirmAction): Button("확인", role: .cancel, action: confirmAction)
        case .sessionExpired: Button("확인", role: .cancel) {}
        case .error: Button("확인") {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .confirmDelete(let username, _): Text("\(username) 계정의 회원을 탈퇴하시겠어요? 되돌릴 수 없는 작업이에요.")
        case .deleteCompleted: Text("회원 탈퇴가 완료됐어요. 앱을 로그아웃 상태로 전환할게요.")
        case .sessionExpired: Text("이전의 사용자가 로그아웃 상태로 전환됐어요. 로그인 후 처음부터 다시 시도해주세요.")
        case .error(let message): Text(message)
        }
    }
}
