//
//  RecipeEditorTagsSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/12/26.
//

import SwiftUI

struct RecipeEditorTagsSection: View {
    @Binding var draft: RecipeDraft
    var onShowTagPicker: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 0) {
                RecipeEditorSectionHeaderView(title: "태그", description: "레시피의 카테고리나 핵심 주제를 간략하게 표현해보세요.")
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            RecipeEditorAddActionButton(text: "태그 추가", onAdd: onShowTagPicker)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                if !draft.tagNames.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(draft.tagNames, id: \.self) { tagName in
                                SelectedIngredientItem(
                                    name: tagName,
                                    onDeselect: {
                                        draft.tagNames.removeAll { $0 == tagName }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    .transition(.opacity.animation(.easeInOut))
                }
            }
            HorizontalDivider()
        }
    }
}
