//
//  UserBlocklistMemberView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/24/26.
//

import SwiftUI

struct UserBlocklistMemberView: View {
    @EnvironmentObject private var router: Router
    
    // 현재 회원(member)의 사용자 이름과 같은 프로필 상태 변경 시,
    // 이를 감지해서 재렌더링하기 위해 @ObservedObject로 wrapping 합니다.
    @ObservedObject private var authManager: AuthManager
    
    @StateObject private var viewModel: UserBlocklistMemberViewModel
    
    @State private var presentLearnMore: Bool = false
    
    private var member: CurrentUser? { authManager.currentUser }
    
    private let userItemHorizontalPadding: CGFloat = 20
    private let profileImageSize: CGFloat = 40
    private let userItemProfileImageLabelSpacing: CGFloat = 12
    private let userItemVerticalPadding: CGFloat = 16
    
    init(_ authManager: AuthManager) {
        self.authManager = authManager
        self._viewModel = StateObject(wrappedValue: UserBlocklistMemberViewModel(authManager))
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .initialLoading: LoadingCurtain(title: "회원님이 차단하신 사용자 목록을 불러오고 있어요...")
            case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
            case .content(let pagedBlocklist): getContentView(pagedBlocklist)
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("차단 사용자 관리")
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.prepareDataIfNeeded() }
        .onChange(of: authManager.state, isSessionExpired)
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: Binding.init(isPresenting: $viewModel.alert),
            presenting: viewModel.alert,
            actions: { $0.actions },
            message: { $0.message })
        .sheet(isPresented: $presentLearnMore) {
            UserBlockShowLearnMoreView()
        }
    }
    
    private var emptyContentView: some View {
        Curtain(
            title: "차단한 사용자가 없어요.",
            description: "아직 아무도 차단하지 않았어요.\n다른 사용자가 작성한 레시피, 댓글, 평가 등의 콘텐츠가 보이는 화면에서 특정 사용자를 차단할 수 있어요.",
            actionTitle: "더 알아보기",
            action: { presentLearnMore = true },
            header: {
                Image(systemName: "nosign")
                    .symbolVariant(.fill)
                    .font(.system(size: 40))
                    .padding(6)
                    .foregroundColor(.init(hex: "C2C2C2"))
                    .background(Color.black.opacity(0.075))
                    .clipShape(Circle())
            })
    }
    
    @ViewBuilder
    private func getContentView(_ pagedBlocklist: Paged<UserEssential>) -> some View {
        if pagedBlocklist.isEmpty { emptyContentView }
        else {
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Text(viewModel.totalElementsLabel)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.gray20)
                            .padding(.leading, 20)
                        Spacer()
                        
                        HStack {
                            Button("더 알아보기", action: { self.presentLearnMore = true })
                                .buttonStyle(SmallBorderlessButtonStyle(status: .normal))
                        }
                        .padding(.trailing, 12)
                    }
                    .padding(.top, 4)
                    .padding(.vertical, 8)
                    
                    ForEach(pagedBlocklist.items) { user in
                        BlockedUserRow(user, onUnblockTapped: { viewModel.handleUnblockUser(for: user) })
                            .transition(.opacity.animation(.easeInOut))
                    }
                    .animation(.easeInOut, value: pagedBlocklist.items)
                    
                    ListPageTailView(
                        hasNextPage: pagedBlocklist.hasNextPage,
                        onAppearAction: viewModel.loadMoreBlocklist
                    )
                }
            }
        }
    }
    
    private func isSessionExpired(oldState: AuthState, newState: AuthState) {
        if case .authenticated = oldState, case .unauthorized = newState {
            viewModel.alert = .sessionExpired
        }
    }
}

private struct BlockedUserRow: View {
    let user: UserEssential
    let onUnblockTapped: () -> Void

    private let horizontalPadding: CGFloat = 20
    private let verticalPadding: CGFloat = 16
    private let profileImageSize: CGFloat = 40
    private let imageLabelSpacing: CGFloat = 12
    
    init(_ user: UserEssential, onUnblockTapped: @escaping () -> Void) {
        self.user = user
        self.onUnblockTapped = onUnblockTapped
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: imageLabelSpacing) {
                ProfileImageView(imageUrl: user.imageUrl, size: profileImageSize)
                
                HStack(alignment: .center) {
                    Text(user.username)
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button("차단 해제", action: onUnblockTapped)
                        .buttonStyle(CapsuleButtonMediumStyle(status: .secondary))
                }
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            
            // 이미지 오른쪽 끝선에 맞춘 디바이더
            HorizontalDivider(padding: 0)
                .padding(.leading, horizontalPadding + profileImageSize + imageLabelSpacing)
                .padding(.trailing, horizontalPadding)
        }
    }
}

enum UserBlocklistMemberAlert {
    case confirmUnblock(username: String, confirmAction: () -> Void)
    case sessionExpired
    case error(message: String)
    
    var title: String {
        switch self {
        case .confirmUnblock: "사용자 차단 해제"
        case .sessionExpired: "세션 만료"
        case .error: "오류"
        }
    }
    
    @ViewBuilder
    var actions: some View{
        switch self {
        case .confirmUnblock(_, let confirmAction):
            Button("취소") {}
            Button("차단 해제", action: confirmAction);
        case .sessionExpired: Button("확인", role: .cancel) {}
        case .error:
            Button("확인") {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .confirmUnblock(let username, _): Text("\(username) 님을 차단 해제하시겠어요?")
        case .sessionExpired: Text("이전의 사용자가 로그아웃 상태로 전환됐어요. 로그인 후 처음부터 다시 시도해주세요.")
        case .error(let message): Text(message)
        }
    }
}
