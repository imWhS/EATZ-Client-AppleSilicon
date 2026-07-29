//
//  RatingEditorDraftView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/19/25.
//

import SwiftUI

struct RatingEditorDraftView: View {
    @Binding var score: Int
    @Binding var content: String
    @Binding var submissionState: RatingEditorSubmissionState
    @FocusState var isContentFocused: Bool
    
    let textViewScrollID: String

    var body: some View {
        VStack(spacing: 40) {
            // 점수 입력 영역
            VStack(spacing: 16) {
                header(
                    title: "점수",
                    description: "별을 탭해서 레시피의 만족도를 표현해보세요.\n별의 개수로 1점부터 5점까지의 점수가 결정돼요.")
                RatingEditorScorePickerView(score: $score)
                    .disabled(submissionState == .submitting)
                    .opacity(submissionState == .submitting ? 0.25 : 1)
            }

            // 후기 입력 영역
            VStack(spacing: 16) {
                header(
                    title: "후기",
                    description: "레시피에 대한 자세한 생각을 작성해보세요.\n원하지 않으신다면 비워두셔도 돼요.")
                DynamicHeightTextView(
                    text: $content,
                    placeholder: "탭해서 댓글 입력",
                    minHeight: 120,
                    maxHeight: 240,
                    isFocused: $isContentFocused)
                .padding(.horizontal, 20)
                .disabled(submissionState == .submitting)
                .opacity(submissionState == .submitting ? 0.25 : 1)
                
                Color.clear
                    .frame(height: 1)
                    .id(textViewScrollID)
            }
        }
    }
    
    private func header(title: String, description: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
            Text(description)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(Color.gray35)
        }
    }
}
