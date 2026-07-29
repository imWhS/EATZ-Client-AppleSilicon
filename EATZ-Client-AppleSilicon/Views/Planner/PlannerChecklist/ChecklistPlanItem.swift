//
//  ChecklistPlanItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/10/25.
//

import SwiftUI
import Kingfisher

enum ChecklistPlanItemAction {
    case save, unsave, like, unlike, report
}

struct ChecklistPlanItem: View {
    @EnvironmentObject private var router: Router
    
    let plan: ChecklistPlan
    let onAction: (ChecklistPlan, ChecklistPlanItemAction) -> Void
    
    private let cardWidth: CGFloat = 124
    
    init(_ plan: ChecklistPlan, onAction: @escaping (ChecklistPlan, ChecklistPlanItemAction) -> Void) {
        self.plan = plan
        self.onAction = onAction
    }
    
    var body: some View {
        Button(action: { router.push(.recipe(id: plan.recipeId)) }) {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    imageView
                    VStack(spacing: 0) {
                        Text(plan.scheduledAt.formattedMonth)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.gray35)
                        Text(plan.scheduledAt.formattedDay)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.gray35)
                    }
                    .frame(maxWidth: cardWidth / 3.4, maxHeight: cardWidth / 3.4)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(8)
                }
                HStack(alignment: .center, spacing: 2) {
                    VStack(spacing: 4) {
                        RecipeItemEssentialInfoView(
                            cookingTime: plan.recipeCookingTime,
                            prepTime: plan.recipePrepTime,
                            ratingAverageScore: nil,
                            ratingCount: nil,
                            showRating: false
                        )
                    }
                    Spacer()
                    actionMenu
                }
                .padding(12)
            }
            .frame(width: cardWidth)
            .background(.white)
            .cornerRadius(16)
        }
        .buttonStyle(ListItemButtonStyle())
    }
    
    private var imageView: some View {
        KFImage(URL(imageUrlString: plan.recipeImageUrl ?? ""))
            .placeholder {
                ZStack {
                    Rectangle().foregroundStyle(.gray.opacity(0.2))
                    ProgressView()
                }
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: cardWidth, height: cardWidth)
            .clipped()
    }
    
    private var actionMenu: some View {
        Menu {
            if plan.likedRecipeByUser {
                Button {
                    onAction(plan, .unlike)
                } label: {
                    Label("레시피 좋아요 취소", systemImage: "heart.slash")
                }
            } else {
                Button {
                    onAction(plan, .like)
                } label: {
                    Label("레시피 좋아요", systemImage: "heart")
                }
            }
            
            if plan.savedRecipeByUser {
                Button {
                    onAction(plan, .unsave)
                } label: {
                    Label("레시피 저장 취소", systemImage: "bookmark.slash")
                }
            } else {
                Button {
                    onAction(plan, .save)
                } label: {
                    Label("레시피 저장", systemImage: "bookmark")
                }
            }
            
            Button {
                onAction(plan, .report)
            } label: {
                Label("레시피 신고", systemImage: "exclamationmark.bubble")
            }
        } label: {
            ArrowDownCircled20()
                .padding(4)
                .contentShape(Rectangle())
        }
    }
}
