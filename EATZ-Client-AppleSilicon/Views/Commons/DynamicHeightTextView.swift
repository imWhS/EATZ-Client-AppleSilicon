//
//  DynamicHeightTextView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/6/25.
//

import SwiftUI
    
struct DynamicHeightTextView: View {
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat
    let maxHeight: CGFloat
    
    var onSubmit: (() -> Void)? = nil
    let submitsOnReturn: Bool

    @State private var height: CGFloat = 0
    @Environment(\.isFocused) private var isFocused: Bool
    @FocusState private var internalFocus: Bool
    private var externalFocus: FocusState<Bool>.Binding?
    private var keyboardType: UIKeyboardType
    private var autocapitalizationType: UITextAutocapitalizationType
    private var returnKeyType: UIReturnKeyType
    
    // 폰트 설정을 DynamicHeightTextView에서 관리하도록 변경
    private let font: UIFont
    private let padding: EdgeInsets
    private let cornerRadius: CGFloat
    private let stroke: Color
    private let strokeHighlighted: Color
    private let backgroundColor: Color

    init(
        text: Binding<String>,
        placeholder: String = "탭해서 입력",
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat = 120,
        font: UIFont = .systemFont(ofSize: 17, weight: .regular),
        padding: EdgeInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16),
        cornerRadius: CGFloat = 12,
        stroke: Color = Color(uiColor: .systemGray5),
        strokeHighlighted: Color = Color.accentColor,
        backgroundColor: Color = .white,
        isFocused: FocusState<Bool>.Binding? = nil,
        keyboardType: UIKeyboardType = .default,
        autocapitalizationType: UITextAutocapitalizationType = .sentences,
        returnKeyType: UIReturnKeyType = .default,
        onSubmit: (() -> Void)? = nil,
        submitsOnReturn: Bool = false
    ) {
        self._text = text
        self.placeholder = text.wrappedValue.isEmpty ? placeholder : ""
        self.maxHeight = maxHeight
        self.font = font
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.stroke = stroke
        self.strokeHighlighted = strokeHighlighted
        self.backgroundColor = backgroundColor
        self.minHeight = minHeight ?? font.lineHeight
        self.externalFocus = isFocused
        self.keyboardType = keyboardType
        self.autocapitalizationType = autocapitalizationType
        self.returnKeyType = returnKeyType
        self.onSubmit = onSubmit
        self.submitsOnReturn = submitsOnReturn
    }

    var body: some View {
        _UITextView(
            text: $text,
            height: $height,
            placeholder: placeholder,
            font: self.font,
            keyboardType: keyboardType,
            autocapitalizationType: self.autocapitalizationType,
            returnKeyType: self.returnKeyType,
            onSubmit: self.onSubmit,
            submitsOnReturn: self.submitsOnReturn
        )
        .frame(height: min(max(height, minHeight), maxHeight))
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isFocused ? strokeHighlighted : stroke, lineWidth: 1)
        )
    }
}

// MARK: - _UITextView (UIViewRepresentable)

private class CustomUITextView: UITextView {
    // 높이가 변경될 때마다 호출될 클로저
    var onContentHeightChange: ((CGFloat) -> Void)?

    // 뷰의 내부 콘텐츠 크기가 변경될 때마다 이 프로퍼티를 오버라이드하여 높이 변경을 감지
    override var contentSize: CGSize {
        didSet {
            // 소수점 차이로 인한 무한 업데이트 방지를 위해 이전 값과 비교
            if oldValue.height != contentSize.height {
                onContentHeightChange?(contentSize.height)
            }
        }
    }
}

private struct _UITextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
    let placeholder: String
    var placeholderColor: UIColor = UIColor.init(hex: "9E9E9E")
    let font: UIFont
    var isPlaceholderHidden: Bool = true
    var keyboardType: UIKeyboardType = .default
    let autocapitalizationType: UITextAutocapitalizationType
    let returnKeyType: UIReturnKeyType
    let onSubmit: (() -> Void)?
    let submitsOnReturn: Bool

    func makeUIView(context: Context) -> UITextView {
        let textView = CustomUITextView()
        textView.delegate = context.coordinator
        textView.font = self.font
        textView.backgroundColor = .clear
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.keyboardType = keyboardType
        textView.autocapitalizationType = autocapitalizationType
        textView.returnKeyType = self.returnKeyType
        context.coordinator.onSubmit = self.onSubmit
        
        textView.onContentHeightChange = { newHeight in
            DispatchQueue.main.async {
                // 소수점 차이로 인한 무한 업데이트 방지
                if abs(self.height - newHeight) > 1 {
                    self.height = newHeight
                }
            }
        }
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.isHidden = !text.isEmpty
        textView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(
                equalTo: textView.leadingAnchor,
                constant: textView.textContainerInset.left + textView.textContainer.lineFragmentPadding
            ),
            placeholderLabel.trailingAnchor.constraint(
                equalTo: textView.trailingAnchor,
                constant: -(textView.textContainerInset.right + textView.textContainer.lineFragmentPadding)
            ),
            placeholderLabel.topAnchor.constraint(
                equalTo: textView.topAnchor,
                constant: textView.textContainerInset.top
            )
        ])

        context.coordinator.placeholderLabel = placeholderLabel

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // 폰트가 변경되었을 경우를 대비해 업데이트
        if uiView.font != self.font {
            uiView.font = self.font
        }
        
        if uiView.text != self.text {
            uiView.text = self.text
        }
        
        context.coordinator.placeholderLabel?.isHidden = !self.text.isEmpty
        
        recalculateHeight(view: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func recalculateHeight(view: UITextView) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude))
        DispatchQueue.main.async {
            // 소수점 차이로 인한 무한 업데이트 방지를 위해 height 비교
            if abs(self.height - newSize.height) > 1 {
                self.height = newSize.height
            }
        }
    }
    
    // Coordinator는 이전과 동일 (수정 필요 없음)
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: _UITextView
        var placeholderLabel: UILabel?
        var onSubmit: (() -> Void)?

        init(_ parent: _UITextView) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if self.parent.submitsOnReturn && text == "\n" {
                self.parent.onSubmit?()
                return false // 줄바꿈 방지
            }
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            placeholderLabel?.isHidden = !textView.text.isEmpty
            parent.recalculateHeight(view: textView)
        }
    }
}
