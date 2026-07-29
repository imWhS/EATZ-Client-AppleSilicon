//
//  ReportViewN.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/22/26.
//

import SwiftUI

struct ReportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = ReportViewModel()
    private let resource: ReportResource

    init(_ resource: ReportResource) {
        self.resource = resource
    }
    
    var body: some View {
        NavigationStack {   
            Group {
                switch viewModel.state {
                case .initialLoading: LoadingCurtain()
                case .content(let categories):
                    ScrollView {
                        VStack(spacing: 20) {
                            header
                            HorizontalDivider()
                            getCategoriesSection(categories)
                        }
                    }
                    .background(Color.backgroundPrimary)
                case .error(let message): ErrorCurtain(message, onRetry: { viewModel.load(authManager) })
                case .unauthorized: CommonUnauthorizedStateView()
                }
            }
            .navigationTitle("신고 카테고리 지정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                dismissToolbarItem
            }
            .navigationDestination(for: ReportCategory.self) { category in
                ReportDescriptionView(viewModel, category)
            }
        }
        .task { viewModel.loadInitial(resource, authManager) }
        .onChange(of: authManager.currentUser) {
            viewModel.validateAndPrepareUser(authManager)
        }
        .onChange(of: viewModel.routingAction) { _, routingAction in
            switch routingAction {
            case .dismiss: dismiss.callAsFunction()
            case .submitCompleted: viewModel.alert = .submitted(dismissAction: dismiss.callAsFunction)
            case .none: break
            }
        }
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: Binding.init(isPresenting: $viewModel.alert),
            presenting: viewModel.alert,
            actions: { $0.actions },
            message: { $0.message })
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("콘텐츠를 신고하는 이유가 무엇인가요?")
                .font(.system(size: 30, weight: .bold))
            
            VStack(spacing: 20) {
                getVerticalLabels("콘텐츠 작성자", resource.authorUsername)
                getVerticalLabels("콘텐츠의 주요 내용", resource.content, resource.isContentTruncated)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private func getCategoriesSection(_ categories: [ReportCategory]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 4) {
                Group {
                    Text("아래에서 신고하는 이유를 포함하는 카테고리를 탭하세요.")
                    Text("관련 있는 카테고리가 없으면, '기타'를 탭하세요.")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray35)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }
            
            VStack(spacing: 12) {
                ForEach(categories) { category in
                    getCategoryItem(for: category)
                }
            }
        }
    }
    
    private func getCategoryItem(for category: ReportCategory) -> some View {
        VStack {
            NavigationLink(value: category) {
                HStack {
                    Text(category.description)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Image("arrow-right-circled")
                }
                .padding(16)
                .background(.white)
            }
            .buttonStyle(ScaleDownButtonStyle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
    }
    
    private func getVerticalLabels(_ title: String, _ subtitle: String, _ isTruncated: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                Text(title).font(.system(size: 12, weight: .medium))
                Group {
                    (
                        Text(subtitle).foregroundColor(.black)
                        +
                        Text(isTruncated ? "···" : "")
                    )
                }
                .font(.system(size: 17, weight: .medium))
            }
            .foregroundColor(.gray35)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

enum ReportAlert {
    case confirmReport(confirmAction: () -> Void)
    case submitted(dismissAction: () -> Void)
    case userChanged(dismissAction: () -> Void)
    case sessionExpired(dismissAction: () -> Void)
    case error(message: String)
    
    var title: String {
        switch self {
        case .confirmReport: return "신고 제출 확인"
        case .submitted: return "신고 제출 완료"
        case .error: return "오류"
        case .userChanged: return "사용자 변경"
        case .sessionExpired: return "세션 만료"
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .confirmReport(let confirmAction):
            Button("취소", role: .cancel) {}
            Button("제출", role: .destructive, action: confirmAction)
        case .submitted(let dismissAction): Button("확인", action: dismissAction)
        case .userChanged(let dismissAction): Button("확인", action: dismissAction)
        case .sessionExpired(let dismissAction): Button("확인", action: dismissAction)
        case .error: Button("확인", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .confirmReport: Text("신고를 제출할까요? 신고한 내용은 수정 또는, 취소가 불가능해요.")
        case .submitted: Text("제출해주신 신고를 접수했어요.")
        case .error(let message): Text(message)
        case .userChanged: Text("기존과 다른 사용자로 로그인됐어요. 신고 편집을 종료할게요.")
        case .sessionExpired: Text("로그아웃 상태로 전환됐어요. 신고 편집을 종료할게요.")
        }
    }
}

enum ReportState {
    case initialLoading
    case content(_ categories: [ReportCategory])
    case error(_ message: String)
    case unauthorized
}
