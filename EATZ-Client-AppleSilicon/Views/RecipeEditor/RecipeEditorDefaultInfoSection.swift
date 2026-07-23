//
//  RecipeEditorDefaultInfoSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/12/26.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct RecipeEditorDefaultInfoSection: View {
    @Binding var draft: RecipeDraft
    @Binding var localImage: UIImage?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var isProcessingImage: Bool
    
    let onDeletePhotoTapped: () -> Void
    
    private enum FocusableField: Hashable {
        case title
        case url
        case description
    }
    
    @FocusState private var focusedField: FocusableField?
    
    var body: some View {
        VStack(spacing: 0) {
            RecipeEditorSectionHeaderView(title: "기본 정보")
            VStack(spacing: 0) {
                essentialEditView
            }
        }
    }
    
    private var essentialEditView: some View {
        VStack(spacing: 0) {
            RecipeEditorDefaultInfoImageSection(imageUrl: $draft.imageUrl, $localImage, $isProcessingImage, $selectedPhotoItem, onDeletePhotoTapped)
            VStack(spacing: 0) {
                DynamicHeightTextView(
                    text: $draft.title,
                    placeholder: "탭해서 레시피 제목 입력",
                    maxHeight: 240,
                    font: .systemFont(ofSize: 28),
                    padding: .init(top: 20, leading: 0, bottom: 20, trailing: 0),
                    cornerRadius: 0,
                    stroke: .clear,
                    returnKeyType: .next,
                    onSubmit: {
                        focusedField = .url
                    },
                    submitsOnReturn: true
                )
                .focused($focusedField, equals: .title)
                HorizontalDivider(padding: 0)
            }
            .padding(.horizontal, 20)
            VStack(spacing: 0) {
                DynamicHeightTextView(
                    text: $draft.url,
                    placeholder: "탭해서 레시피 URL 주소 입력",
                    font: .systemFont(ofSize: 17),
                    padding: .init(top: 20, leading: 0, bottom: 20, trailing: 0),
                    cornerRadius: 0,
                    stroke: .clear,
                    keyboardType: .URL,
                    autocapitalizationType: .none,
                    returnKeyType: .next,
                    onSubmit: {
                        focusedField = .description
                    },
                    submitsOnReturn: true
                )
                .focused($focusedField, equals: .url)
                HorizontalDivider(padding: 0)
            }
            .padding(.horizontal, 20)
            VStack(spacing: 0) {
                DynamicHeightTextView(
                    text: $draft.description,
                    placeholder: "탭해서 레시피 설명 입력",
                    maxHeight: 240,
                    font: .systemFont(ofSize: 17),
                    padding: .init(top: 20, leading: 0, bottom: 20, trailing: 0),
                    cornerRadius: 0,
                    stroke: .clear,
                )
                .focused($focusedField, equals: .description)
                HorizontalDivider(padding: 0)
            }
            .padding(.horizontal, 20)
        }
    }
}
