//
//  RecipeView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/16/25.
//

import SwiftUI

struct RecipeView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel: RecipeViewModel
    
    init(recipeId: Int64) {
        _viewModel = StateObject(wrappedValue: RecipeViewModel(recipeId: recipeId))
    }
    
    var body: some View {
        recipeView
            .navigationBarTitleDisplayMode(.inline)
            .task(id: authManager.currentUser) {
                viewModel.authManager = authManager
                viewModel.prepareDataIfNeeded()
            }
            .alert(
                viewModel.alert?.title ?? "",
                isPresented: isAlertPresented(),
                presenting: viewModel.alert,
                actions: { _ in Button("확인", role: .cancel) {} },
                message: { $0.message })
            .sheet(item: $viewModel.sheet, content: buildSheet)
    }
    
    private var recipeView: some View {
        Group {
            switch viewModel.viewState {
            case .initialLoading: LoadingCurtain(title: "레시피를 불러오고 있어요...")
            case .loaded: RecipeDetailView(router: router).environmentObject(viewModel)
            case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
            }
        }
    }
    
    @ViewBuilder
    private func buildSheet(item: RecipeSheet) -> some View {
        switch item {
        case .plannerDatePicker(let recipeId): PlannerDatePicker(for: recipeId)
        }
    }
    
    private func isAlertPresented() -> Binding<Bool> {
        return Binding(
            get: {
                self.viewModel.alert != nil },
            set: { isPresented in
                if !isPresented { self.viewModel.alert = nil } } )
    }
}
