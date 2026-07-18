//
//  ManagementProfileView.swift (EditProfileView)
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/29/25.
//

import SwiftUI
import PhotosUI

struct ManagementProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = ManagementProfileViewModel()
    
    var body: some View {
        mainContent
            .task {
                viewModel.setDismissAction(dismiss.callAsFunction)
                viewModel.prepareDataIfNeeded()
            }
            .onChange(of: viewModel.selectedPhotoItem) { viewModel.handleProfileImageSelection() }
            .alert(
                viewModel.alert?.title ?? "",
                isPresented: Binding(
                    get: { self.viewModel.alert != nil },
                    set: { isPresented in if !isPresented { self.viewModel.alert = nil } }),
                presenting: viewModel.alert,
                actions: { $0.actions },
                message: { $0.message })
            .sheet(item: $viewModel.sheet, onDismiss: viewModel.prepareDataIfNeeded, content: buildSheet)
    }
    
    @ViewBuilder
    private func buildSheet(for type: ManagementProfileSheet) -> some View {
        switch type {
        case .bioEditor: BioEditor()
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .initialLoading: LoadingCurtain(title: "회원님의 프로필 정보를 불러오고 있어요...")
                case .content: contentView
                case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
                case .unauthorized: CommonUnauthorizedStateView()
                }
            }
            .navigationTitle("프로필 관리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { dismissToolbarItem }
        }
    }

    private var contentView: some View {
        ZStack {
            normalStateView
                .opacity(viewModel.isProcessing ? 0.5 : 1)
                .disabled(viewModel.isProcessing)
            if viewModel.isProcessing {
                processingOverlayView
            }
        }
        .animation(.easeIn(duration: 0.2), value: viewModel.isProcessing)
    }
    
    private var normalStateView: some View {
        ScrollView {
            VStack(spacing: 0) {
                usernameSection
                imageSection
                bioSection
            }
            .padding(.vertical, 10)
        }
        .transition(.opacity)
    }
    
    private var processingOverlayView: some View {
        ProgressView("잠시만 기다려주세요...")
            .padding(32)
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 1)
            .transition(.opacity.combined(with: .scale(scale: 1.1)))
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                viewModel.updateCurrentUserBeforeDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
    
    private var usernameSection: some View {
        ManagementProfileSection(
            title: "사용자 이름",
            footers: [
                "EATZ에서 레시피 또는 댓글, 평가 등의 활동을 할 때 다른 사람들에게 보여지는 이름이에요.",
                "사용자의 고유 이름이기 때문에 변경할 수 없어요."
            ]
        ) {
            if viewModel.username != "" {
                Text(viewModel.username)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.black)
            }
        }
    }
    
    private var imageSection: some View {
        ManagementProfileSection(
            title: "대표 사진",
            footers: [
                "EATZ에서 레시피 또는 댓글, 평가 등의 활동을 할 때 다른 사람들에게 보여지는 사진이에요.",
                "등록한 사진이 없다면, 기본 프로필 사진이 보여져요."
            ]
        ) {
            if let imageUrl = viewModel.imageUrl {
                ProfileImageView(imageUrl: imageUrl, size: 140)
            }
        } actions: {
            HStack {
                Spacer()
                if viewModel.imageUrl != nil {
                    Button("삭제", action: viewModel.handleDeleteProfileImage)
                        .buttonStyle(SmallRoundedButtonStyle(type: .danger))
                }
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Text(viewModel.imageUrl != nil ? "변경" : "설정")
                            
                    }
                    .buttonStyle(SmallRoundedButtonStyle(type: .secondary))
            }
        }
    }
    
    private var bioSection: some View {
        ManagementProfileSection(
            title: "소개",
            footers: ["다른 사람들이 회원님이 EATZ에 등록한 레시피를 볼 때, 회원님에 대해 알 수 있게 도와줄 문구에요."]
        ) {
            if viewModel.bio != "" {
                Text(viewModel.bio)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.black)
            }
        } actions: {
            HStack {
                Spacer()
                if viewModel.bio != "" {
                    Button("삭제", action: viewModel.handleDeleteBio)
                        .buttonStyle(SmallRoundedButtonStyle(type: .danger))
                }
                Button("편집", action: viewModel.handleEditBio)
                    .buttonStyle(SmallRoundedButtonStyle(type: .secondary))
            }
        }
    }
}

private struct ManagementProfileSection<Content: View, Actions: View>: View {
    let title: String
    let footers: [String]?
    @ViewBuilder let content: Content
    @ViewBuilder let actions: Actions?
    
    init(title: String,
         footers: [String]? = nil,
         @ViewBuilder content: () -> Content) where Actions == EmptyView {
        self.title = title
        self.footers = footers
        self.content = content()
        self.actions = EmptyView()
    }
    
    init(title: String,
         footers: [String]? = nil,
         @ViewBuilder content: () -> Content,
         @ViewBuilder actions: () -> Actions) {
        self.title = title
        self.footers = footers
        self.content = content()
        self.actions = actions()
    }
    
    private var titleText: some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.black)
    }
    
    @ViewBuilder
    private var footerTextList: some View {
        if let descriptions = footers {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(descriptions, id: \.self) { description in
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.init(hex: "828282"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        } else { EmptyView() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Group {
                    titleText
                    content
                    VStack(spacing: 12) {
                        footerTextList
                        actions
                    }
                }
                .padding(.horizontal, 20)
            }
            
            HorizontalDivider()
        }
        .padding(.vertical, 10)
    }
}

enum ManagementProfileSheet: Identifiable {
    case bioEditor
    
    var id: String {
        switch self {
        case .bioEditor: return "bioEditor"
        }
    }
}

enum ManagementProfileAlert: Identifiable {
    case deleteImageConfirmation(confirmAction: () -> Void)
    case imageDeleted(confirmAction: () -> Void)
    case deleteBioConfirmation(confirmAction: () -> Void)
    case bioDeleted(confirmAction: () -> Void)
    case bioUpdated(confirmAction: () -> Void)
    case userChanged(dismissAction: () -> Void)
    case sessionExpired(dismissAction: () -> Void)
    case error(message: String)
    
    var id: String {
        switch self {
        case .deleteImageConfirmation: return "deleteImageConfirmation"
        case .imageDeleted: return "imageDeleted"
        case .deleteBioConfirmation: return "deleteBioConfirmation"
        case .bioDeleted: return "bioDeleted"
        case .bioUpdated: return "bioUpdated"
        case .userChanged: return "userChanged"
        case .sessionExpired: return "sessionExpired"
        case .error: return "error"
        }
    }
    
    var title: String {
        switch self {
        case .deleteImageConfirmation: "대표 사진 삭제"
        case .imageDeleted: "대표 사진 삭제 완료"
        case .deleteBioConfirmation: "소개 삭제"
        case .bioDeleted: "소개 삭제 완료"
        case .bioUpdated: "소개 업데이트 완료"
        case .userChanged: "사용자 변경"
        case .sessionExpired: "세션 만료"
        case .error: "오류"
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .deleteImageConfirmation: Text("회원님의 대표 사진을 삭제할까요? 삭제된 사진은 복구할 수 없어요.")
        case .imageDeleted: Text("회원님의 대표 사진을 삭제했어요.")
        case .deleteBioConfirmation: Text("회원님의 대표 사진을 삭제할까요? 삭제된 사진은 복구할 수 없어요.")
        case .bioDeleted: Text("회원님의 소개를 삭제했어요.")
        case .bioUpdated: Text("편집하신 소개를 업데이트했어요.")
        case .userChanged: Text("기존과 다른 사용자로 로그인됐어요. 프로필 관리를 종료할게요.")
        case .sessionExpired: Text("로그아웃 상태로 전환됐어요. 프로필 관리를 종료할게요.")
        case .error(let message): Text(message)
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .deleteImageConfirmation(let confirmAction):
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive, action: confirmAction)
        case .imageDeleted(let confirmAction):
            Button("확인", action: confirmAction)
        case .deleteBioConfirmation(let confirmAction):
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive, action: confirmAction)
        case .bioDeleted(let confirmAction):
            Button("확인", action: confirmAction)
        case .bioUpdated(let confirmAction):
            Button("확인", action: confirmAction)
        case .userChanged(let dismissAction):
            Button("확인", action: dismissAction)
        case .sessionExpired(let dismissAction):
            Button("확인", action: dismissAction)
        case .error:
            Button("확인") {}
        }
    }
    
    var alert: Alert {
        switch self {
        case .userChanged(let dismissAction):
            return Alert(
                title: Text("사용자 변경"),
                message: Text("기존과 다른 사용자로 로그인됐어요. 프로필 관리를 종료할게요."),
                dismissButton: .default(Text("확인"), action: dismissAction))
        case .sessionExpired(let dismissAction):
            return Alert(
                title: Text("세션 만료"),
                message: Text("로그아웃 상태로 전환됐어요. 프로필 관리를 종료할게요."),
                dismissButton: .default(Text("확인"), action: dismissAction))
        case .error(let message):
            return Alert(
                title: Text("오류"),
                message: Text(message),
                dismissButton: .default(Text("확인")))
        case .deleteImageConfirmation(let confirmAction):
            return Alert(
                title: Text("대표 이미지 삭제"),
                message: Text("회원님의 대표 이미지를 삭제할까요? 삭제된 이미지는 복구할 수 없어요."),
                dismissButton: .default(Text("확인"), action: confirmAction))
        case .imageDeleted(let confirmAction):
            return Alert(
                title: Text("대표 이미지 삭제 완료"),
                message: Text("회원님의 대표 이미지를 삭제했어요."),
                dismissButton: .default(Text("확인"), action: confirmAction))
        case .deleteBioConfirmation(let confirmAction):
            return Alert(
                title: Text("소개 삭제"),
                message: Text("회원님의 소개를 삭제할까요? 삭제된 소개 내용은 복구할 수 없어요."),
                dismissButton: .default(Text("확인"), action: confirmAction))
        case .bioDeleted(let confirmAction):
            return Alert(
                title: Text("소개 삭제 완료"),
                message: Text("회원님의 소개를 삭제했어요."),
                dismissButton: .default(Text("확인"), action: confirmAction))
        case .bioUpdated(let confirmAction):
            return Alert(
                title: Text("소개 편집 업데이트 완료"),
                message: Text("편집하신 소개를 업데이트했어요."),
                dismissButton: .default(Text("확인"), action: confirmAction))
        }
    }
}

#Preview {
    ManagementProfileView()
}
