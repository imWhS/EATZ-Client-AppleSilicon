//
//  RecipeEssentailCommonActionMenuView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 12/3/25.
//

import SwiftUI

struct RecipeBasicCommonActionMenuView<ExtraMenu: View>: View {
    let recipe: RecipeBasic
    let currentUser: CurrentUser?
    
    var onUpdateTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onToggleSaveTapped: (() -> Void)?
    var onAddToPlannerTapped: (() -> Void)?
    var onReportTapped: (() -> Void)?
    
    @ViewBuilder let extraMenu: () -> ExtraMenu
    
    init(
        recipe: RecipeBasic,
        currentUser: CurrentUser?,
        onUpdateTapped: (() -> Void)? = nil,
        onDeleteTapped: (() -> Void)? = nil,
        onToggleSaveTapped: (() -> Void)? = nil,
        onAddToPlannerTapped: (() -> Void)? = nil,
        onReportTapped: (() -> Void)? = nil) where ExtraMenu == EmptyView
    {
        self.recipe = recipe
        self.currentUser = currentUser
        self.onUpdateTapped = onUpdateTapped
        self.onDeleteTapped = onDeleteTapped
        self.onToggleSaveTapped = onToggleSaveTapped
        self.onAddToPlannerTapped = onAddToPlannerTapped
        self.onReportTapped = onReportTapped
        self.extraMenu = { EmptyView() }
    }
    
    init(
        recipe: RecipeBasic,
        currentUser: CurrentUser?,
        onUpdateTapped: (() -> Void)? = nil,
        onDeleteTapped: (() -> Void)? = nil,
        onToggleSaveTapped: (() -> Void)? = nil,
        onAddToPlannerTapped: (() -> Void)? = nil,
        onReportTapped: (() -> Void)? = nil,
        @ViewBuilder extraMenu: @escaping () -> ExtraMenu)
    {
        self.recipe = recipe
        self.currentUser = currentUser
        self.onUpdateTapped = onUpdateTapped
        self.onDeleteTapped = onDeleteTapped
        self.onToggleSaveTapped = onToggleSaveTapped
        self.onAddToPlannerTapped = onAddToPlannerTapped
        self.onReportTapped = onReportTapped
        self.extraMenu = extraMenu
    }
    
    var body: some View {
        extraMenu()
        
        if ExtraMenu.self != EmptyView.self {
            Divider()
        }
        
        if recipe.ownedByUser {
            if let onUpdateTapped = onUpdateTapped {
                Button(action: onUpdateTapped) {
                    Label("수정", systemImage: "pencil")
                }
            }
            if let onDeleteTapped = onDeleteTapped {
                Button(role: .destructive, action: onDeleteTapped) {
                    Label("삭제", systemImage: "trash")
                }
            }
        }
        
        if let onToggleSaveTapped = onToggleSaveTapped {
            Divider()
            if recipe.savedByUser {
                Button(action: onToggleSaveTapped) {
                    Label("저장 취소", systemImage: "bookmark.slash")
                }
            } else {
                Button(action: onToggleSaveTapped) {
                    Label("저장", systemImage: "bookmark")
                }
            }
        }
        
        if let onAddToPlannerTapped = onAddToPlannerTapped {
            Button(action: onAddToPlannerTapped) {
                Label("플래너에 추가", systemImage: "plus")
            }
        }
        
        if !recipe.ownedByUser || currentUser == nil {
            Divider()
            if let onReportTapped = onReportTapped {
                Button(action: onReportTapped) {
                    Label("신고", systemImage: "exclamationmark.bubble")
                }
            }
        }
    }
}
