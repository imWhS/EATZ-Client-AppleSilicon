//
//  AffiliateLinkNoticeView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/19/26.
//

import SwiftUI

struct AffiliateLinkNoticeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var alert: AffiliateLinkNoticeAlert?
    @State private var isLoading: Bool = false
    
    private var item: PurchaseItem?
    
    private var titleLabel: String {
        if let name = item?.name {
            return "온라인에서 \(name) 구입"
        } else {
            return "온라인에서 준비물 둘러보기"
        }
    }
    
    private var subtitleLabel: String {
        return "지금 쇼핑몰로 이동해서 필요한 재료와 도구를 빠르고 간편하게 준비해보세요."
    }
    
    init(_ item: PurchaseItem? = nil) {
        self.item = item
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                Spacer()
                interactionSection
            }
            .navigationTitle(titleLabel)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                titleToolbarItem
                dismissToolbarItem
            }
        }
        .alert(
            alert?.title ?? "",
            isPresented:
                Binding(
                    get: { self.alert != nil },
                    set: { isPresented in if (!isPresented) { self.alert = nil } }),
            presenting: alert,
            actions: { $0.actions },
            message: { $0.message })
    }
    
    private var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(titleLabel)
                .font(.headline)
                .opacity(0)
        }
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                self.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .frame(width: 58, height: 58)
                    .foregroundStyle(Color.gray2)
                Image("shopping-26")
                    .foregroundColor(Color.gray50)
                    .offset(x: -2)
            }
            
            VStack(spacing: 20) {
                Text(titleLabel)
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                Text(subtitleLabel)
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.gray50)
            }
            .padding(20)
        }
    }
    
    private var interactionSection: some View {
        VStack(spacing: 0) {
            Button(action: handleGoShoppingTapped) {
                HStack(spacing: 4) {
                    Text("쇼핑몰로 이동")
                    Image("external-link-14")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(RoundedButtonStyle(.primary, .large))
            .padding(.bottom, 10)
            Text("이 화면을 통해 이동할 페이지는 쿠팡 파트너스 활동의 일환으로, 이에 따른 일정액의 수수료를 제공받습니다.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gray50)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 20)
    }
    
    private func handleGoShoppingTapped() {
        isLoading = true
        AffiliateService.shared.getAffiliate(item) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    guard let url = URL(string: response.url) else {
                        self.alert = .error(message: "올바르지 않은 URL 주소예요.")
                        return
                    }
                    self.openURL(url)
                case .failure(let networkError):
                    self.alert = .error(message: networkError.userMessage)
                }
            }
        }
    }
}

enum AffiliateLinkNoticeAlert {
    case error(message: String)
    
    var title: String {
        switch self {
        case .error: return "오류"
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .error(let message):
            Text("쇼핑몰로 이동하지 못했어요. \(message) 다시 시도해보세요.")
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .error:
            Button("확인") {}
        }
    }
}

#Preview {
    AffiliateLinkNoticeView()
}
