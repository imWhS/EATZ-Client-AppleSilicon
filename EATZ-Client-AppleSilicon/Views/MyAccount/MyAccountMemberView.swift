//
//  MyAccountMemberView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/31/26.
//

import SwiftUI

struct MyAccountMemberView: View {
    @EnvironmentObject private var router: Router
    
    // 현재 회원(member)의 사용자 이름과 같은 프로필 상태 변경 시,
    // 이를 감지해서 재렌더링하기 위해 @ObservedObject로 wrapping 합니다.
    @ObservedObject private var authManager: AuthManager
    
    @StateObject private var viewModel: MyAccountMemberViewModel
    
    private var member: CurrentUser? { authManager.currentUser }
    
    init(_ authManager: AuthManager) {
        self.authManager = authManager
        self._viewModel = StateObject(wrappedValue: MyAccountMemberViewModel(authManager))
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                switch viewModel.state {
                case .initialLoading: LoadingCurtain(title: "회원님의 계정 정보를 불러오고 있어요...")
                case .content: contentView
                case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
                }
            }
            .background(Color.backgroundPrimary)
            .toolbar(.hidden, for: .navigationBar)
            .navigationTitle(MainTabItems.myAccount.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ViewRoute.self) { route in
                DestinationView(route)
            }
        }
        .task { viewModel.prepareDataIfNeeded() }
        .onChange(of: router.path) { _, path in
            if path.isEmpty { viewModel.prepareDataIfNeeded() }
        }
        .onChange(of: authManager.state, isSessionExpired)
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: Binding(
                get: { viewModel.alert != nil },
                set: { isPresented in if !isPresented { viewModel.alert = nil } }),
            presenting: viewModel.alert,
            actions: { $0.actions },
            message: { $0.message })
        .fullScreenCover(
            item: $viewModel.fullScreenCover,
            onDismiss: viewModel.prepareDataIfNeeded,
            content: buildFullScreenCover)
        .sheet(
            item: $viewModel.sheet,
            onDismiss: viewModel.prepareDataIfNeeded,
            content: buildSheet)
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                MyAccountHeader(
                    member,
                    onEditProfileTapped: { self.viewModel.fullScreenCover = .managementProfile },
                    onRegisterRecipeTapped: viewModel.presentRecipeEditor,
                    onSettingsTapped: { self.router.push(.myAccountSettings) } )
                MyAccountRecipeDisclosureCarouselSection(
                    "내 레시피",
                    viewModel.createRecipeCountLabel(viewModel.myRecipeCount),
                    viewModel.myRecipesPaged,
                    onPresentRecipesTapped: { self.router.push(.myRecipes) },
                    onRecipeTapped: { id in self.router.push(.recipe(id: id)) })
                MyAccountPantryKitchenwareSection(
                    count: viewModel.myKitchenwareCount,
                    onSearchKitchenwares: { self.viewModel.sheet = .kitchenwarePicker },
                    onDetailTapped: { self.router.push(.myKitchenwarePantry) })
                MyAccountPantryIngredientSection(
                    count: viewModel.myIngredientCount,
                    onSearchIngredients: { self.viewModel.sheet = .ingredientPicker },
                    onPresentLikedIngredients: { self.viewModel.sheet = .likedIngredientList },
                    onDetailTapped: { self.router.push(.myIngredientPantry) })
                MyAccountRecipeDisclosureCarouselSection(
                    "저장한 레시피",
                    viewModel.createRecipeCountLabel(viewModel.savedRecipeCount),
                    viewModel.savedRecipesPaged,
                    onPresentRecipesTapped: { self.router.push(.savedRecipes) },
                    onRecipeTapped: { id in self.router.push(.recipe(id: id)) })
                BasicMenuRow(
                    "좋아하는 레시피",
                    .navigation,
                    viewModel.createRecipeCountLabel(viewModel.likedRecipeCount),
                    onTapped: { self.router.push(.likedRecipes) })
                BasicMenuRow(
                    "평가한 레시피",
                    false,
                    .navigation,
                    viewModel.createRecipeCountLabel(viewModel.ratedRecipeCount),
                    onTapped: { self.router.push(.ratedRecipes) })
            }
        }
        .refreshable { await viewModel.refresh() }
    }
    
    @ViewBuilder
    private func buildSheet(for type: MyAccountMemberSheet) -> some View {
        switch type {
        case .kitchenwarePicker: ExploreKitchenwaresView()
        case .ingredientPicker: ExploreIngredientsView()
        case .likedIngredientList: LikedIngredientsView()
        }
    }
    
    @ViewBuilder
    private func buildFullScreenCover(for type: MyAccountMemberFullScreenCover) -> some View {
        switch type {
        case .managementProfile: ManagementProfileView()
        case .recipeEditor: RecipeEditor(mode: .create) {
            viewModel.alert = .createdRecipe
        }
        }
    }
    
    private func isSessionExpired(oldState: AuthState, newState: AuthState) {
        if case .authenticated = oldState, case .unauthorized = newState {
            viewModel.alert = .sessionExpired
        }
    }
}

enum MyAccountMemberAlert {
    case createdRecipe
    case sessionExpired
    case error(message: String)
    
    var title: String {
        switch self {
        case .createdRecipe: return "새 레시피 등록"
        case .sessionExpired: return "세션 만료"
        case .error: return "오류"
        }
    }
    
    @ViewBuilder
    var actions: some View {
        switch self {
        case .createdRecipe: Button("확인", role: .cancel) {}
        case .sessionExpired: Button("확인", role: .cancel) {}
        case .error: Button("확인", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    var message: some View {
        switch self {
        case .createdRecipe: Text("새 레시피를 등록했어요.")
        case .sessionExpired: Text("이전의 사용자가 로그아웃 상태로 전환됐어요. 로그인 후 처음부터 다시 시도해주세요.")
        case .error(let message): Text(message)
        }
    }
}

enum MyAccountMemberSheet: Identifiable {
    case kitchenwarePicker
    case ingredientPicker
    case likedIngredientList
    
    var id: Int { hashValue }
}

enum MyAccountMemberFullScreenCover: Identifiable {
    case recipeEditor
    case managementProfile
    
    var id: Int { hashValue }
}

enum MyAccountMemberState: Equatable {
    case initialLoading
    case content
    case error(message: String)
}
