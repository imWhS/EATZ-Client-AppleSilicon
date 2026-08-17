//
//  ChecklistPlanItem.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/10/25.
//

import SwiftUI
import Kingfisher

struct ChecklistPlanItem: View {
    @EnvironmentObject private var router: Router
    
    let plan: ChecklistPlan
    let action: (ChecklistPlan, ChecklistPlanItemAction) -> Void
    
    private let cardWidth: CGFloat = 134
    
    init(_ plan: ChecklistPlan, action: @escaping (ChecklistPlan, ChecklistPlanItemAction) -> Void) {
        self.plan = plan
        self.action = action
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
                HStack(alignment: .center, spacing: 0) {
                    RecipeItemEssentialInfoView(
                        cookingTime: plan.recipeCookingTime,
                        prepTime: plan.recipePrepTime,
                        ratingAverageScore: nil,
                        ratingCount: nil,
                        showRating: false
                    )
                    Spacer()
                    actionMenu
                }
                .padding(10)
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
            .contentShape(Rectangle())
            .clipped()
    }
    
    private var actionMenu: some View {
        Menu {
            if plan.likedRecipeByUser {
                Button {
                    action(plan, .unlike)
                } label: {
                    Label("레시피 좋아요 취소", systemImage: "heart.slash")
                }
            } else {
                Button {
                    action(plan, .like)
                } label: {
                    Label("레시피 좋아요", systemImage: "heart")
                }
            }
            
            if plan.savedRecipeByUser {
                Button {
                    action(plan, .unsave)
                } label: {
                    Label("레시피 저장 취소", systemImage: "bookmark.slash")
                }
            } else {
                Button {
                    action(plan, .save)
                } label: {
                    Label("레시피 저장", systemImage: "bookmark")
                }
            }
            
            Button(role: .destructive) {
                action(plan, .report)
            } label: {
                Label("레시피 신고", systemImage: "exclamationmark.bubble")
            }
        } label: {
            ArrowDownCircled24()
                .padding(4)
                .contentShape(Rectangle())
        }
    }
}

enum ChecklistPlanItemAction {
    case save, unsave, like, unlike, report
}
