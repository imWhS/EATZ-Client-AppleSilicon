//
//  CookableView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/2/25.
//

import SwiftUI

struct CookableView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var authManager: AuthManager
    
    @StateObject private var viewModel = CookableViewModel()
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
            ScrollView {
                VStack(spacing: 0) {
                    if !isSearchFieldFocused { header }
                    filterSection
                }
            }
            .safeAreaInset(edge: .bottom) {
                CookableSearchButton(isShowing: !isSearchFieldFocused, action: {
                    router.push(.cookable(searchCriteria: viewModel.searchCriteria))
                })
            }
            .animation(.easeInOut(duration: 0.3), value: isSearchFieldFocused)
            .background(Color.backgroundPrimary.ignoresSafeArea(edges: [.top, .bottom]))
            .contentShape(Rectangle())
            .onTapGesture { isSearchFieldFocused = false }
            .navigationTitle(MainTabItems.cookable.title)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ViewRoute.self) { route in
                DestinationView(route)
            }
            .onChange(of: authManager.isLoggedIn) { _, isLoggedIn in
                if isLoggedIn == false {
                    viewModel.searchCriteria.isCookableOnly = false
                }
            }
        }
    }
    
    private var header: some View {
        VStack {
            Text("지금, 요리할만한\n레시피를 찾아볼까요?")
                .font(.system(size: 34, weight: .bold))
                .lineSpacing(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
        .padding(.horizontal, 40)
        .padding(.top, 80)
        .padding(.bottom, 12)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private var filterSection: some View {
        VStack(spacing: 8) {
            CookableKeywordFieldBar(keyword: $viewModel.searchCriteria.keyword, isFocused: $isSearchFieldFocused)
            
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
                        subtitleLabel: "1회 제공량",
                        action: { viewModel.sheet = .servingsPicker })
                }
                .padding(.horizontal, 20)
                HorizontalDivider().padding(.horizontal, 20)
                CookableFilterToggle(
                    isCookableOnly: $viewModel.searchCriteria.isCookableOnly,
                    isEnabled: authManager.isLoggedIn,
                    action: viewModel.toggleCookableOnly)
            }
        }
    }
}

#Preview {
    CookableView()
}
