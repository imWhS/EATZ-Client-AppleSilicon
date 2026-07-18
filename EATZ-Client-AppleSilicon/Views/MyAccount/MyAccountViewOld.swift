//
//  MyAccountView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/26/25.
//

import SwiftUI

struct MyAccountViewOld: View {
    @EnvironmentObject private var router: Router
    @StateObject private var viewModel = MyAccountViewModelOld()
    
    var body: some View {
        mainContent
            .task(id: viewModel.currentUser) {
                viewModel.prepareDataIfNeeded()
            }
            .onChange(of: router.path) { _, path in
                if path.isEmpty {
                    print("test")
                    viewModel.prepareDataIfNeeded() }
            }
            .alert(item: $viewModel.alert) { $0.alert }
            .alert(isPresented: $viewModel.presentSaveSuccessAlert) {
                Alert(title: Text("레시피 등록 완료"))
            }
            .fullScreenCover(
                item: $viewModel.fullScreenCover,
                onDismiss: {},
                content: buildFullScreenCover)
            .sheet(
                item: $viewModel.sheet,
                onDismiss: viewModel.prepareDataIfNeeded,
                content: buildSheet)
    }
    
    @ViewBuilder
    private var mainContent: some View {
        NavigationStack(path: $router.path) {
            Group {
                switch viewModel.viewState {
                case .loading: LoadingCurtain(title: "회원님의 정보를 불러오고 있어요...")
                case .loaded: loadedView
                case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
                case .unauthorized: MyAccountUnauthorizedView(onLogIn: viewModel.requireAuthView)
                }
            }
            .background(Color(hex: "F9F9F9"))
            .toolbar(.hidden, for: .navigationBar)
            .navigationTitle(MainTabItems.myAccount.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ViewRoute.self) { route in
                DestinationView(route)
            }
        }
    }
    
    private var loadedView: some View {
        ScrollView {
            VStack(spacing: 0) {
                MyAccountHeader(
                    viewModel.currentUser,
                    onEditProfileTapped: { self.viewModel.sheet = .managementProfile },
                    onRegisterRecipeTapped: viewModel.presentRecipeEditor,
                    onSettingsTapped: { self.router.push(.myAccountSettings)} )
//                MyAccountRecipeDisclosureCarouselSection(
//                    "내 레시피",
//                    viewModel.myRecipesResponse,
//                    onPresentRecipesTapped: { router.push(.myRecipes) },
//                    onRecipeTapped: { id in router.push(.recipe(id: id)) }
//                )
                MyAccountPantryKitchenwareSection(
                    count: viewModel.myKitchenwareCount,
                    onSearchKitchenwares: { self.viewModel.sheet = .kitchenwarePicker },
                    onDetailTapped: { router.push(.myKitchenwarePantry) }
                )
                MyAccountPantryIngredientSection(
                    count: viewModel.myIngredientCount,
                    onSearchIngredients: { self.viewModel.sheet = .ingredientPicker },
                    onPresentLikedIngredients: { self.viewModel.sheet = .likedIngredientList },
                    onDetailTapped: { router.push(.myIngredientPantry) }
                )
//                MyAccountRecipeDisclosureCarouselSection(
//                    "저장한 레시피",
//                    viewModel.savedRecipesResponse,
//                    onPresentRecipesTapped: { router.push(.savedRecipes) },
//                    onRecipeTapped: { id in router.push(.recipe(id: id)) }
//                )
                MyAccountSummaryRowSection(
                    label: "좋아하는 레시피",
                    count: viewModel.likedRecipeCount,
                    onDisclosureTapped: { router.push(.likedRecipes) })
                MyAccountSummaryRowSection(
                    label: "평가한 레시피",
                    count: viewModel.ratedRecipeCount,
                    onDisclosureTapped: { router.push(.ratedRecipes) })
            }
        }
        .refreshable { await viewModel.refresh()}
    }
    
    @ViewBuilder
    private func buildSheet(for type: MyAccountSheetOld) -> some View {
        switch type {
        case .managementProfile: ManagementProfileView()
        case .kitchenwarePicker: ExploreKitchenwaresView()
        case .ingredientPicker: ExploreIngredientsView()
        case .likedIngredientList: LikedIngredientsView()
        }
    }
    
    @ViewBuilder
    private func buildFullScreenCover(for type: MyAccountFullScreenCoverOld) -> some View {
        switch type {
        case .recipeEditor: RecipeEditor(mode: .create) {
            viewModel.presentSaveSuccessAlert = true
            viewModel.loadMyRecipes()
        }
        }
    }
}

#Preview {
    MyAccountViewOld()
        .environmentObject(Router())
}


struct MyAccountUnauthorizedView: View {
    let onLogIn: () -> Void
    
    var body: some View {
        mainContent
    }
    
    private var mainContent: some View {
        VStack {
            MyAccountHeader(nil, onEditProfileTapped: nil, onRegisterRecipeTapped: nil, onSettingsTapped: nil)
            coverSection
            bottomActionSection
        }
    }
    
    private var coverSection: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Text("내 계정")
                    .font(.system(size: 30, weight: .bold))
                Text("나만의 레시피를 만들고, 가지고 있는 재료와 도구를 보관함에 추가해 체계적으로 관리할 수 있어요. 또한, EATZ에서의 모든 활동과 계정을 관리할 수 있어요.")
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init(hex: "A1A1A1"))
            }
            .padding(20)
            Spacer()
        }
    }
    
    private var bottomActionSection: some View {
        VStack(spacing: 0) {
            HorizontalDivider()
            VStack(spacing: 12) {
                Button(action: onLogIn) {
                    Text("이메일로 시작").frame(maxWidth: .infinity)
                }
                .buttonStyle(BigRoundedButtonStyle(type: .primary))
                Text("로그인 또는 가입 후 계속 진행할 수 있어요.")
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.init(hex: "A1A1A1"))
            }
            .padding(20)
        }
    }
}

