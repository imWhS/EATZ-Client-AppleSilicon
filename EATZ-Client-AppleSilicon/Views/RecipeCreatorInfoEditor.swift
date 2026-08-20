//
//  RecipeCreatorInfoSheet.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/1/25.
//

import SwiftUI

struct RecipeCreatorInfoEditor: View {
    @Binding var name: String?
    @Binding var url: String?
    
    @State private var localSourceName: String
    @State private var localSourceUrl: String
    
    @FocusState private var isSourceNameFieldFocused: Bool
    @FocusState private var isSourceUrlFieldFocused: Bool
    
    @FocusState private var focusedField: FormField?
    enum FormField: Hashable {
        case name, url
    }
    
    @Environment(\.dismiss) private var dismiss
    
    init(name: Binding<String?>, url: Binding<String?>) {
        self._name = name
        self._url = url
        
        _localSourceName = State(initialValue: name.wrappedValue ?? "")
        _localSourceUrl = State(initialValue: url.wrappedValue ?? "")
    }
    
    private var isFormValid: Bool {
        // '출처 이름'이 비어있지 않거나,
        let isNameValid = !localSourceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        // '출처 링크'가 올바른 URL 형태일 경우 true를 반환합니다.
        let isUrlValid = localSourceUrl.isValidURL
        
        return isNameValid || isUrlValid
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Group {
                            // 출처 이름 입력 필드
                            FloatingLabeledTextField(
                                floatingLabel: "이름",
                                placeholder: "",
                                isInvalid: false,
                                text: $localSourceName,
                                isFocused: $isSourceNameFieldFocused,
                                onSubmit: {
                                isSourceUrlFieldFocused = true
                            })
                            
                            // 출처 URL 주소 입력 필드
                            FloatingLabeledTextField(
                                floatingLabel: "URL 주소",
                                placeholder: "",
                                isInvalid: false,
                                text: $localSourceUrl,
                                isFocused: $isSourceUrlFieldFocused,
                                keyboardType: .URL,
                                submitLabel: .done,
                                onSubmit: {
                                if isFormValid { saveAndDismiss() }
                            })
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    GuideView(guides: [
                        "레시피의 창작자가 있는 경우, 창작자의 정보를 확인할 수 있는 출처를 추가해야 돼요.",
                        "출처를 추가하면 다른 사람들에게 레시피와 레시피의 창작자 정보가 함께 공개돼요.",
                        "'이름'에 창작자의 이름 또는 원문이 게시되어 있는 매체(서비스)의 이름을 입력하세요.",
                        "'URL 주소'에 창작자의 프로필, 연락처 또는 원문이 게시되어 있는 매체(서비스)로 이동할 수 있는 URL 주소를 입력하세요."
                    ])
                    Spacer()
                }
                .navigationTitle("출처 편집")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("완료", action: saveAndDismiss)
                            .fontWeight(.semibold)
                            .tint(Color.accentColor)
                            .buttonStyle(.borderedProminent)
                            .disabled(!isFormValid)
                    }
                }
                .onAppear {
                    focusedField = .name
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func saveAndDismiss() {
        name = localSourceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : localSourceName
        url = localSourceUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : localSourceUrl
        dismiss()
    }
}

// MARK: - Preview
#if DEBUG
struct CreatorInfoSheet_Preview_Wrapper: View {
    @State private var sourceName: String? = "요리하는 손"
    @State private var sourceUrl: String? = "https://youtube.com/eatz"
    
    var body: some View {
        Text("프리뷰용")
            .sheet(isPresented: .constant(true)) {
                RecipeCreatorInfoEditor(name: $sourceName, url: $sourceUrl)
            }
    }
}

#Preview {
    CreatorInfoSheet_Preview_Wrapper()
}
#endif
