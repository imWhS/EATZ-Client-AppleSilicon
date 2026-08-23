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
    
    @FocusState private var focusedField: RecipeEditorDefaultInfoFocusableField?
    
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
            RecipeEditorDefaultInfoImageView(
                imageUrl: $draft.imageUrl,
                $localImage,
                $isProcessingImage,
                $selectedPhotoItem,
                onDeletePhotoTapped)
            RecipeEditorDefaultInfoTextView(
                $draft.title,
                placeholder: "탭해서 레시피 제목 입력",
                fontSize: 28,
                maxHeight: 240,
                onSubmit: { focusedField = .url },
                submitOnReturn: true,
                field: .title,
                focusedField: $focusedField)
            RecipeEditorDefaultInfoTextView(
                $draft.url,
                placeholder: "탭해서 레시피 URL 주소 입력",
                maxHeight: 120,
                keyboardType: .URL,
                onSubmit: { focusedField = .description },
                submitOnReturn: true,
                field: .url,
                focusedField: $focusedField)
            RecipeEditorDefaultInfoTextView(
                $draft.description,
                placeholder: "탭해서 레시피 설명 입력",
                maxHeight: 480,
                onSubmit: { focusedField = .description },
                submitOnReturn: false,
                field: .description,
                focusedField: $focusedField)
        }
    }
}

struct RecipeEditorDefaultInfoTextView: View {
    @Binding var text: String
    let placeholder: String
    let fontSize: CGFloat
    let maxHeight: CGFloat
    let keyboardType: UIKeyboardType
    let onSubmit: () -> Void
    let returnKeyType: UIReturnKeyType
    let submitOnReturn: Bool
    
    let field: RecipeEditorDefaultInfoFocusableField
    @FocusState.Binding var focusedField: RecipeEditorDefaultInfoFocusableField?
    
    init(
        _ text: Binding<String>,
        placeholder: String,
        fontSize: CGFloat = 17,
        maxHeight: CGFloat,
        keyboardType: UIKeyboardType = .default,
        onSubmit: @escaping () -> Void,
        returnKeyType: UIReturnKeyType = .next,
        submitOnReturn: Bool,
        field: RecipeEditorDefaultInfoFocusableField,
        focusedField: FocusState<RecipeEditorDefaultInfoFocusableField?>.Binding)
    {
        self._text = text
        self.placeholder = placeholder
        self.fontSize = fontSize
        self.maxHeight = maxHeight
        self.keyboardType = keyboardType
        self.onSubmit = onSubmit
        self.returnKeyType = returnKeyType
        self.submitOnReturn = submitOnReturn
        self.field = field
        self._focusedField = focusedField
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DynamicHeightTextView(
                text: $text,
                placeholder: placeholder,
                maxHeight: maxHeight,
                font: .systemFont(ofSize: fontSize),
                padding: .init(top: 20, leading: 0, bottom: 20, trailing: 0),
                cornerRadius: 0,
                stroke: .clear,
                strokeHighlighted: .clear,
                keyboardType: keyboardType,
                returnKeyType: returnKeyType,
                onSubmit: onSubmit,
                submitOnReturn: submitOnReturn
            )
            .focused($focusedField, equals: field)
            HorizontalDivider(padding: 0)
        }
        .padding(.horizontal, 20)
    }
}

enum RecipeEditorDefaultInfoFocusableField: Hashable {
    case title
    case url
    case description
}
