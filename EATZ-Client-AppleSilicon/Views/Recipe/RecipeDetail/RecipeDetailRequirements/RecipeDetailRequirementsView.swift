//
//  RecipeDetailRequirementsView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/18/25.
//

import SwiftUI

struct RecipeDetailRequirementsView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject private var viewModel: RecipeDetailRequirementsViewModel
    
    init(viewModel: RecipeDetailRequirementsViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            viewStateContent
        }
        .task(id: authManager.currentUser) { viewModel.prepareDataIfNeeded() }
    }
    
    @ViewBuilder
    private var viewStateContent: some View {
        switch viewModel.viewState {
        case .idle: Color.clear.onAppear { viewModel.resetAndLoadAll() }
        case .loading: LoadingCurtain(title: "레시피를 요리하기 위해 필요한 준비물 목록을 불러오고 있어요...")
        case .loaded(let kitchenwares, let ingredients, let cookability):
            RecipeDetailRequirementsContentView(
                isLoggedIn: authManager.isLoggedIn,
                kitchenwares: kitchenwares,
                ingredients: ingredients,
                cookability: cookability,
                onShowRecipeTapped: {},
                onAuth: authManager.requireAuthView,
                onAddAllRequirements: { },
                onAction: viewModel.handleAction)
        case .error(let error): ErrorCurtain(error, onRetry: viewModel.resetAndLoadAll)
        }
    }
}

struct RecipeDetailRequirementsContentView: View {
    let isLoggedIn: Bool
    let kitchenwares: [RecipeKitchenware]
    let ingredients: [RecipeIngredient]
    let cookability: RecipeDetailRequirementsCookability
    let onShowRecipeTapped: () -> Void
    let onAuth: () -> Void
    let onAddAllRequirements: () -> Void
    let onAction: (RecipeDetailRequirementsAction) -> Void
    
    var missingKitchenwareCount: Int? {
        switch cookability {
        case .cookable: return nil
        case .uncookable(_, let missingKitchenwareCount): return missingKitchenwareCount
        }
    }
    
    var missingIngredientCount: Int? {
        switch cookability {
        case .cookable: return nil
        case .uncookable(let missingIngredientCount, _): return missingIngredientCount
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            VStack(spacing: 0) {
                titleSection
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    RecipeDetailRequirementsKitchenwareSection(
                        isLoggedIn: isLoggedIn,
                        kitchenwares: kitchenwares,
                        missingKitchenwareCount: missingKitchenwareCount,
                        onAction: onAction)
                    RecipeDetailRequirementsIngredientSection(
                        isLoggedIn: isLoggedIn,
                        ingredients: ingredients,
                        missingIngredientCount: missingIngredientCount,
                        onAction: onAction)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var titleSection: some View {
        RecipeDetailTitle("준비물")
            .padding(.vertical, 10)
    }
    
    private var headerSection: some View {
        Group {
            if isLoggedIn { recipeRequirementsContentHeader }
            else { RecipeDetailRequirementsHeaderGuest(onAuth: onAuth) }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    private var recipeRequirementsContentHeader: some View {
        Group {
            switch cookability {
            case .cookable:
                RecipeDetailRequirementsHeaderCookable(onShowRecipeTapped: onShowRecipeTapped)
            case .uncookable(let missingIngredientCount, let missingKitchenwareCount):
                RecipeDetailRequirementsHeaderUncookable(
                    missingKitchenwareCount: missingKitchenwareCount,
                    missingIngredientCount: missingIngredientCount,
                    onAddAllRequirements: onAddAllRequirements
                )
            }
        }
        .padding(.horizontal, 20)
    }
}
