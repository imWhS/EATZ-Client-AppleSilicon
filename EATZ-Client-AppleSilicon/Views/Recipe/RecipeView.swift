//
//  RecipeView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/19/25.
//

import SwiftUI
import Kingfisher

struct RecipeView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @EnvironmentObject private var router: Router
    
    @StateObject private var viewModel: RecipeViewModel
    
    @State private var imageHeight: CGFloat = .zero
    init(
        recipeId: Int64,
    ) {
        _viewModel = StateObject(wrappedValue: RecipeViewModel(recipeId: recipeId))
    }

    var body: some View {
        Group {
            currentStateView
            .transition(.opacity)
        }
        .task {
            if case .loading = viewModel.state {
                viewModel.fetchRecipe()
            }
        }
        .onChange(of: authManager.isLoggedIn) { _ in
            print("[RecipeView] 전역 인증 상태가 변경되어, 뷰의 모든 데이터를 새로 고칠게요.")
            viewModel.refreshAllData()
        }
        .animation(.easeInOut(duration: 0.15), value: viewModel.state)
        .navigationTitle("레시피")
        .alert(isPresented: $viewModel.isErrorAlertPresented) {
            Alert(
                title: Text("오류"),
                message: Text(viewModel.errorAlertMessage ?? "알 수 없는 오류가 발생했어요. 오류가 계속 반복되면 사용자 지원 센터에 문의해주세요."),
                dismissButton: .default(Text("확인"))
            )
        }
    }
    
    @ViewBuilder
    private var currentStateView: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("레시피를 불러오는 중이에요...")
                .toolbarBackground(.visible, for: .tabBar)
            
        case .loaded(let recipe):
            RecipeDetailView(
//                showAuthModal: $authManager.loginPrompt,
                recipe: recipe,
                ingredientListState: viewModel.ingredientListState,
                isLoggedIn: authManager.isLoggedIn,
                triggerIngredientFetch: {
                    viewModel.fetchIngredients()
                },
                isLiked: viewModel.isLiked,
                likedCount: viewModel.likedCount,
                onLikeTapped: viewModel.toggleLike,
                onRatingTapped: { id in
                    router.push(.rating(recipeId: recipe.id, recipeImageUrl: recipe.imageUrl, recipeTitle: recipe.title, recipeAuthorUsername: recipe.author.username))
                },
                onIngredientAddTapped: { id in
                    viewModel.addIngredientToUser(ingredientId: id)
                },
                onIngredientRemoveTapped: { id in
                    viewModel.removeIngredientFromUser(ingredientId: id)
                },
                isUpdatingIngredient: viewModel.isUpdatingIngredient,
                onLogIn: { authManager.isRequiredAuth = .logIn() }
            )
        case .error(let message):
            VStack(spacing: 20) {
                VStack(alignment: .center, spacing: 12) {
                    Text("레시피를 불러오던 중 오류가 발생했어요.")
                        .font(.title)
                    Text(message)
                        .font(.body)
                }
                Button(action: {
                    viewModel.fetchRecipe()
                }) {
                    Text("다시 불러오기")
                        .fontWeight(.bold)
                }
                .buttonStyle(BigRoundedButtonStyle(type: .primary))
            }
        }
    }
}

struct RecipeDetailView: View {
//    @Binding var showAuthModal: AuthPresentMessageType?
    
    let recipe: RecipeResponse
    let ingredientListState: RecipeIngredientListState
    let isLoggedIn: Bool
    let triggerIngredientFetch: () -> Void
    let isLiked: Bool
    let likedCount: Int64
    let onLikeTapped: () -> Void
    let onRatingTapped: (Int64) -> Void
    let onIngredientAddTapped: (Int64) -> Void
    let onIngredientRemoveTapped: (Int64) -> Void
    let isUpdatingIngredient: [Int64: Bool]
    let onLogIn: () -> Void
    
    @State private var scrollOffset: CGPoint = .zero
    @State private var imageHeight: CGFloat = .zero
    
    @ViewBuilder
    private var ingredientsSection: some View {
        switch ingredientListState {
        case .idle:
            Text("재료 목록 불러오기 대기 중")
        case .loading:
            ProgressView("재료 목록을 불러오는 중...")
        case .loaded(let ingredients):
            if isLoggedIn {
                RecipeIngredientsView(
                    ingredients: ingredients,
                    onMainAction: { print("레시피 보기") },
                    onAddTapped: { id in
                        onIngredientAddTapped(id)
                    },
                    onActionTapped: { id, action in
                        onIngredientRemoveTapped(id)
                    },
                    isUpdatingIngredient: isUpdatingIngredient
                )
            } else {
                RecipeIngredientsPublicView(
                    ingredients: ingredients,
                    onAction: onLogIn
                )
            }
        case .error(let message):
            Text(message)
                .foregroundColor(.red)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {   
                ImageView(imageUrl: recipe.imageUrl, imageHeight: imageHeight)
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        RecipeCategoryView(categories: recipe.categories)
                        RecipeTitleView(title: recipe.title)
                    }
                    HorizontalDividerView()
                    InteractionView(cookingTime: recipe.cookingTime, prepTime: recipe.prepTime, isLiked: isLiked, likedCount: likedCount, onLikeTapped: onLikeTapped)
                    AuthorView(author: recipe.author)
                    Text(recipe.description)
                        .font(.system(size: 16))
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HorizontalDividerView()
                    HStack(spacing: 20) {
                        DoubleLineButton(firstIcon: "recipe-rating", firstTitle: "\(recipe.rating?.averageScore ?? 0.0)", secondTitle: "평가", isShowArrow: true, isShowDivider: true) {
                            print("평가 pressed")
                            onRatingTapped(recipe.id)
                        }
                        VerticalDividerView(horizontalPadding: 0)
                        DoubleLineButton(firstIcon: "recipe-rating", firstTitle: "\(recipe.commentCount)", secondTitle: "댓글 수", isShowArrow: true) {
                            print("댓글 수 pressed")
                        }
                    }
                    .padding(.horizontal, 20)
                    HorizontalDividerView()
                    ingredientsSection
                        .task {
                            if case .idle = ingredientListState {
                                triggerIngredientFetch()
                            }
                        }
                }
            }
            .trackOffset(into: $scrollOffset)
            
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .onReadSize { size in
            imageHeight = size.width * (2/3)
            print("이미지 높이: \(imageHeight)")
        }
    }
}

private struct ImageView: View {
    let imageUrl: String
    let imageHeight: CGFloat
    
    var body: some View {
        
        if let url = URL(string: imageUrl) {
            KFImage(url)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: imageHeight)
                .clipped()
                .ignoresSafeArea()
        } else {
            Color.gray.frame(height: imageHeight)
        }
    }
}

struct RecipeCategoryView: View {
    let categories: [RecipeCategory]

    var body: some View {
        if !categories.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(categories) { category in
                        Text("# \(category.name)")
                            .font(.system(size: 14))
                            .foregroundStyle(Color("BEBEB9"))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct RecipeTitleView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 26, weight: .bold))
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
}

struct InteractionView: View {
    let cookingTime: Int?
    let prepTime: Int?
    let isLiked: Bool
    let likedCount: Int64
    let onLikeTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                if let cookingTime = cookingTime, let prepTime = prepTime {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image("recipe-cooking-time")
                            Text("\(cookingTime)분")
                                .font(.system(size: 16, weight: .bold))
                        }
                        
                        Text("+ 준비 시간 \(prepTime)분")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.init("BEBEB9"))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    print("test")
                }) {
                    Text("레시피 보기")
                        .fontWeight(.bold)
                }
                .buttonStyle(BigRoundedButtonStyle(type: .primary))
            }
            .padding(.horizontal, 20)
            
            HStack {
                VerticalAlignedButtonView(image: "like", title: (likedCount == 0) ? "좋아요" : "\(likedCount)") {
                    onLikeTapped()
                }
                VerticalAlignedButtonView(image: "save", title: "플래너에 추가") {
                    print("플래너에 추가")
                }
                VerticalAlignedButtonView(image: "save", title: "저장") {
                    print("저장")
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct AuthorView: View {
    let author: Author
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ProfileImageView(imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgRpKzCD0qaHBwI03JFHGakAPxGdv5yOIk-vkhqp0nY3B_y9J-Nn5PQwu34h0Aq81jXuA&usqp=CAU", size: 28)
                    Text(author.username)
                        .font(.system(size: 12, weight: .bold))
                        .lineLimit(1)
                    Spacer()
                    Image("arrow-right-recipe-profile")
                }
                
                Text("1인 가구, 자취생이 보다 잘 해먹을 수 있는 레시피를 만들어보려고 노력합니다 :-)")
                    .font(.system(size: 12))
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(Color.init("696969"))
            }
            .padding(12)
            .background(Color.init("F8F8F8"))
            .cornerRadius(8)
        }
        .padding(.horizontal, 20)
    }
}
 
//#Preview {
//    RecipeView(recipeId: 1)
//}
