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
        
        // 외부에서 받은 값으로 내부 상태를 초기화
        _localSourceName = State(initialValue: name.wrappedValue ?? "")
        _localSourceUrl = State(initialValue: url.wrappedValue ?? "")
    }
    
    private var isFormValid: Bool {
        // '출처 이름'이 비어있지 않거나,
        let isNameValid = !localSourceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        // '출처 링크'가 올바른 URL 형태일 경우 true를 반환합니다.
        let isUrlValid = isValidUrl(string: localSourceUrl)
        
        return isNameValid || isUrlValid
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Group {
                            Text("레시피의 원작자 또는 원문이 있는 경우, 관련 정보를 포함하면 다른 사용자들이 레시피의 출처를 확인할 수 있어요.")
                            Text("'이름'에 원작자의 이름 또는 원문이 게시되어 있는 매체(서비스)의 이름을 입력하세요.")
                            Text("'URL 주소'에 원작자의 이름 또는 원문이 게시되어 있는 매체(서비스)로 이동할 수 있는 URL 주소를 입력하세요.")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.init(hex: "8F8F8F"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack(spacing: 20) {
                        // 출처 이름 입력 필드
                        FloatingTitleTextField(title: "이름", placeholder: "", isInvalid: false, text: $localSourceName, isFocused: $isSourceNameFieldFocused, onSubmit: {
                            isSourceUrlFieldFocused = true
                        })
                        
                        // 출처 URL 주소 입력 필드
                        FloatingTitleTextField(title: "URL 주소", placeholder: "", isInvalid: false, text: $localSourceUrl, isFocused: $isSourceUrlFieldFocused, keyboardType: .URL, submitLabel: .done, onSubmit: {
                            if isFormValid {
                                saveAndDismiss()
                            }
                        })
                    }
                    Spacer()
                }
                .padding(20)
                .navigationTitle("출처 설정")
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
    
    private func isValidUrl(string: String) -> Bool {
        // 공백을 제거한 문자열이 비어있으면 유효하지 않음
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.isEmpty {
            return false
        }
        
        // URL 객체를 생성하고, scheme과 host가 있는지 확인하여 기본적인 유효성을 검사
        if let url = URL(string: trimmedString),
           url.scheme != nil,
           url.host != nil {
            return true
        }
        
        return false
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
