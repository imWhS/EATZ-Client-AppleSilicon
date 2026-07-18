//
//  CookableView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/2/25.
//

import SwiftUI

struct CookableView: View {
    @StateObject private var viewModel = CookableViewModel()
    @EnvironmentObject private var router: Router
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        mainContent
            .sheet(item: $viewModel.sheet) { item in
                switch item {
                case .totalTimePicker:
                    TotalTimePicker(totalTimeInMinutes: viewModel.searchCriteria.maxTotalTime ?? 0) { totalTime in
                        viewModel.searchCriteria.maxTotalTime = totalTime
                    }
                case .servingsPicker:
                    ServingsPicker(servings: viewModel.searchCriteria.servings ?? 0) { servings in
                        viewModel.searchCriteria.servings = servings
                    }
                }
            }
    }
    
    private var mainContent: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 0) {
                if !isSearchFieldFocused { header }
                filterSection
                Spacer()
                CookableSearchButton(isShowing: !isSearchFieldFocused, action: {
                    router.push(.cookable(searchCriteria: viewModel.searchCriteria))
                })
            }
            .animation(.easeInOut(duration: 0.3), value: isSearchFieldFocused)
            .background(Color.init(hex: "F9F9F9"))
            .contentShape(Rectangle())
            .onTapGesture { isSearchFieldFocused = false }
            .navigationTitle("바로 요리")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ViewRoute.self) { route in
                DestinationView(route)
            }
        }
    }
    
    private var header: some View {
        VStack {
            Text("지금, 요리할\n레시피를 찾아볼까요?")
                .font(.system(size: 30, weight: .bold))
                .lineSpacing(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
        .padding(.horizontal, 40)
        .padding(.top, 40)
        .padding(.bottom, 12)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private var filterSection: some View {
        VStack(spacing: 8) {
            CookableKeywordFieldView(keyword: $viewModel.searchCriteria.keyword, isFocused: $isSearchFieldFocused)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    CookableFilterButton(
                        titleLabel: viewModel.totalTimeLabel,
                        subtitleLabel: "최대 소요 시간",
                        action: { viewModel.sheet = .totalTimePicker })
                    VerticalDivider(padding: 0)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 20)
                    CookableFilterButton(
                        titleLabel: viewModel.servingsLabel,
                        subtitleLabel: "제공량",
                        action: { viewModel.sheet = .servingsPicker })
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                HorizontalDivider()
                    .padding(.horizontal, 20)
                CookableFilterToggleButton(
                    isCookableOnly: $viewModel.searchCriteria.isCookableOnly,
                    action: viewModel.toggleCookableOnly)
            }
        }
    }
}

private struct CookableButtonDescriptionsView: View {
    let titleLabel: String
    let subtitleLabel: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titleLabel)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.black)
            Text(subtitleLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.init(hex: "C2C2C2"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CookableFilterButton: View {
    let titleLabel: String
    let subtitleLabel: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 4) {
                CookableButtonDescriptionsView(
                    titleLabel: titleLabel,
                    subtitleLabel: subtitleLabel)
                Spacer()
                ArrowDownCircled26()
            }
            .padding(20)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(CookableButtonHighlightStyle())
    }
}

private struct CookableFilterToggleButton: View {
    @Binding var isCookableOnly: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                CookableButtonDescriptionsView(
                    titleLabel: "요리 가능",
                    subtitleLabel: "보관함 속 재료, 도구로 요리할 수 있는 레시피만 찾습니다.")
                Spacer()
                CheckToggleCircled(isToggled: isCookableOnly)
            }
            .padding(20)
            .contentShape(Rectangle())
        }
        .buttonStyle(CookableButtonHighlightStyle())
        .padding(.horizontal, 20)
    }
}

private struct CookableSearchButton: View {
    let isShowing: Bool
    let action: () -> Void
    
    var body: some View {
        if isShowing {
            VStack(spacing: 12) {
                Button(action: action) {
                    HStack(alignment: .center) {
                        Image("today-search")
                    }
                }
                .buttonStyle(TodaySearchButtonStyle())
            }
            .padding(20)
            .padding(.bottom, 12)
        } else {
            EmptyView()
        }
    }
}

private struct CookableKeywordFieldView: View {
    @Binding var keyword: String
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                TextField("키워드", text: $keyword)
                    .font(.system(size: 20, weight: .semibold))
                    .focused($isFocused)
                
                Text("레시피 제목, 내용")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.init(hex: "C5C5C7"))
            }
            Spacer()
            if (isFocused && !keyword.isEmpty) {
                Button(action: {
                    keyword = ""
                }) {
                    Image("remove-14")
                }
                .padding(.vertical, 6)
                .padding(.leading, 6)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 4)
        .padding(.horizontal, 20)
        .onTapGesture { isFocused = true }
        .padding(.top, 20)
    }
}

struct CookableButtonHighlightStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.init(hex: "ECECEC").opacity(configuration.isPressed ? 1 : 0)
            )
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .cornerRadius(18)
    }
}

#Preview {
    CookableView()
}
