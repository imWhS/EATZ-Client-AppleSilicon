//
//  PlanItemView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/3/25.
//

import SwiftUI
import Kingfisher

enum PlannerPlanItemAction {
    case removeFromPlanner, addToPlanner
    case like, unlike
    case save, unsave
    case report
}

struct PlannerPlanItem: View {
    let plan: PlannerPlan
    let onAction: (PlannerPlan, PlannerPlanItemAction) -> Void
    
    @EnvironmentObject private var router: Router
    private let cardWidth: CGFloat = (UIScreen.main.bounds.width - 40 - 8) / 2
    
    init(
        _ plan: PlannerPlan,
        onAction: @escaping (PlannerPlan, PlannerPlanItemAction) -> Void) {
        self.plan = plan
        self.onAction = onAction
    }
    
    var body: some View {
        Button(action: {
            router.push(.recipe(id: plan.recipeId))
        }) {
            ZStack(alignment: .bottom) {
                imageView
                bottomView
            }
            .frame(width: cardWidth)
            .background(.white)
            .cornerRadius(16)
        }
        .buttonStyle(ListItemButtonStyle())
        .padding(.vertical, 20)
    }
    
    var imageView: some View {
        KFImage(URL(imageUrlString: plan.recipeImageUrl))
            .placeholder {
                Rectangle().foregroundStyle(.gray.opacity(0.2))
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: cardWidth, height: cardWidth)
            .clipped()
    }
    
    private var bottomView: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: cardWidth / 2)
            HStack(alignment: .center, spacing: 4) {
                RecipeItemEssentialInfoView(
                    cookingTime: plan.recipeCookingTime,
                    prepTime: plan.recipePrepTime,
                    ratingAverageScore: plan.ratingIndicatorSummary?.averageScore,
                    ratingCount: plan.ratingIndicatorSummary?.count,
                    foregroundStyle: .white)
                Spacer()
                actionMenu(perform: { action in self.onAction(plan, action) })
            }
            .padding(12)
        }
    }
    
    private func actionMenu(perform action: @escaping (PlannerPlanItemAction) -> Void) -> some View {
        Menu {
            Button(role: .destructive) {
                action(.removeFromPlanner)
            } label: {
                Label("이 날짜에서 제거", systemImage: "minus.circle")
            }
            
            Button {
                action(.addToPlanner)
            } label: {
                Label("다른 날짜에도 추가", systemImage: "calendar.badge.plus")
            }
            
            Divider()
            
            if plan.likedRecipeByUser {
                Button {
                    action(.unlike)
                } label: {
                    Label("레시피 좋아요 취소", systemImage: "heart.slash")
                }
            } else {
                Button {
                    action(.like)
                } label: {
                    Label("레시피 좋아요", systemImage: "heart")
                }
            }
            
            if plan.savedRecipeByUser {
                Button {
                    action(.unsave)
                } label: {
                    Label("레시피 저장 취소", systemImage: "bookmark.slash")
                }
            } else {
                Button {
                    action(.save)
                } label: {
                    Label("레시피 저장", systemImage: "bookmark")
                }
            }
            Button(role: .destructive) {
                action(.report)
            } label: {
                Label("레시피 신고", systemImage: "exclamationmark.bubble")
            }
        } label: {
            ArrowDownCircled20()
                .padding(.horizontal, 8)
                .contentShape(Rectangle())
        }
    }
}
