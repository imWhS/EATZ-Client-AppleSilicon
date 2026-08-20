//
//  RecipeEditorOtherOptionsSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/12/26.
//

import SwiftUI

struct RecipeEditorOtherOptionsSection: View {
    @Binding var draft: RecipeDraft
    
    var timeSummaryLabel: String
    var servingsLabel: String
    var creatorSummaryLabel: String
    var onShowTimePicker: () -> Void
    var onShowServingsPicker: () -> Void
    var onShowCreatorInfoEditor: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            buttonRow(
                title: timeSummaryLabel,
                description: "레시피를 완성하기 위해 필요한 시간을 설정하세요.",
                onAction: onShowTimePicker)
            buttonRow(
                title: servingsLabel, // 제공량
                description: "레시피를 한 번 요리했을 때 완성될 요리의 양을 설정하세요.",
                onAction: onShowServingsPicker)
            buttonRow(
                title: creatorSummaryLabel,
                description: "제 3자에 의해 만들어진 레시피라면, 창작자에 대한 정보를 알려주세요.",
                onAction: onShowCreatorInfoEditor)
            toggleRow(title: "댓글", description: "다른 사람이 레시피에 댓글을 추가할 수 있는 기능을 켜고 끄세요.", isOn: $draft.isCommentEnabled)
        }
    }
    
    @ViewBuilder
    private func buttonRow(title: String, description: String? = nil, onAction: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Button(action: onAction) {
                HStack {
                    RecipeEditorSectionHeaderView(
                        title: title,
                        description: description,
                        hasPadding: false
                    )
                    Spacer()
                    ArrowCircledDown24()
                }
                .padding(10)
            }
            .buttonStyle(SquareHighlightButtonStyle(cornerRadius: 12))
        }
        .padding(10)
        HorizontalDivider()
    }
    
    @ViewBuilder
    private func toggleRow(title: String, description: String? = nil, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            RecipeEditorSectionHeaderView(
                title: title,
                description: description,
                hasPadding: false
            )
        }
        .tint(.accentColor)
        .padding(20)
        HorizontalDivider()
    }
}
