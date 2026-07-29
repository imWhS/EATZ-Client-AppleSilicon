//
//  ReportDescriptionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/23/26.
//

import SwiftUI

struct ReportDescriptionView: View {
    @ObservedObject var viewModel: ReportViewModel
    @FocusState var isDescriptionFocused: Bool
    
    let category: ReportCategory
    
    init(_ viewModel: ReportViewModel, _ category: ReportCategory) {
        self.viewModel = viewModel
        self.category = category
    }
    
    var body: some View {
        Group {
            if case .content = viewModel.state {
                ScrollView {
                    VStack(spacing: 20) {
                        Group {
                            getVerticalLabels("신고 카테고리", category.description)
                            HorizontalDivider(padding: 0)
                            descriptionGuide
                            DynamicHeightTextView(
                                text: $viewModel.description,
                                placeholder: "탭해서 설명 입력",
                                minHeight: 120,
                                maxHeight: 240,
                                isFocused: $isDescriptionFocused
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
                .background(Color.backgroundPrimary)
            } else if case .unauthorized = viewModel.state {
                CommonUnauthorizedStateView()
            } else { EmptyView() }
        }
        .navigationTitle("신고 콘텐츠 설명 추가")
        .toolbar {
            submitToolbarItem
        }
        .task {
            viewModel.category = category
        }
    }
    
    private var descriptionGuide: some View {
        VStack(spacing: 4) {
            Group {
                Text("선택하신 카테고리와 관련해 콘텐츠에서 문제의 소지가 있는 부분이 무엇인지 더 자세히 설명해주세요.")
                Text("원하지 않으신다면 설명을 생략하셔도 돼요.")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.init(hex: "A1A1A1"))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var submitToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("완료", action: viewModel.handleSubmit).fontWeight(.semibold)
        }
    }
    
    private func getVerticalLabels(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.init(hex: "A1A1A1"))
            Text(subtitle).foregroundColor(.primary)
                .font(.system(size: 17, weight: .medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

