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
    let submitOnReturn: Bool

    @State private var height: CGFloat = 0
    @State private var isEditing: Bool = false
    
    @Environment(\.isFocused) private var isFocused: Bool
    @FocusState private var internalFocus: Bool
    private var externalFocus: FocusState<Bool>.Binding?
    private var keyboardType: UIKeyboardType
    private var autocapitalizationType: UITextAutocapitalizationType
    private var returnKeyType: UIReturnKeyType
    
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
        cornerRadius: CGFloat = 14,
        stroke: Color = Color.gray8,
        strokeHighlighted: Color = Color.accentColor,
        backgroundColor: Color = .white,
        isFocused: FocusState<Bool>.Binding? = nil,
        keyboardType: UIKeyboardType = .default,
        autocapitalizationType: UITextAutocapitalizationType = .sentences,
        returnKeyType: UIReturnKeyType = .default,
        onSubmit: (() -> Void)? = nil,
        submitOnReturn: Bool = false
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
        self.submitOnReturn = submitOnReturn
    }

    var body: some View {
        _UITextView(
            text: $text,
            height: $height,
            isFocused: $isEditing,
            placeholder: placeholder,
            font: font,
            keyboardType: keyboardType,
            autocapitalizationType: autocapitalizationType,
            returnKeyType: returnKeyType,
            onSubmit: onSubmit,
            submitOnReturn: submitOnReturn
        )
        .frame(height: min(max(height, minHeight), maxHeight))
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(isEditing ? strokeHighlighted : stroke, lineWidth: 1)
        )
    }
}

// MARK: - _UITextView (UIViewRepresentable)

private class CustomUITextView: UITextView {
    // 높이가 변경될 때마다 호출될 클로저입니다.
    var onContentHeightChange: ((CGFloat) -> Void)?

    // 이 프로퍼티를 오버라이드함으로써, 뷰의 내부 콘텐츠 크기가 변경될 때마다 높이 변경을 감지합니다.
    override var contentSize: CGSize {
        didSet {
            // 소수점 차이로 인한 의도하지 않은 업데이트 방지를 위해 이전 값과 비교합니다.
            if oldValue.height != contentSize.height {
                onContentHeightChange?(contentSize.height)
            }
        }
    }
}

private struct _UITextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var isFocused: Bool
    
    let placeholder: String
    var placeholderColor: UIColor = UIColor(Color.gray25)
    let font: UIFont
    var isPlaceholderHidden: Bool = true
    var keyboardType: UIKeyboardType = .default
    let autocapitalizationType: UITextAutocapitalizationType
    let returnKeyType: UIReturnKeyType
    let onSubmit: (() -> Void)?
    let submitOnReturn: Bool

    func makeUIView(context: Context) -> UITextView {
        let textView = CustomUITextView()
        textView.delegate = context.coordinator
        textView.font = font
        textView.backgroundColor = .clear
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.keyboardType = keyboardType
        textView.autocapitalizationType = autocapitalizationType
        textView.returnKeyType = returnKeyType
        context.coordinator.onSubmit = onSubmit
        
        textView.onContentHeightChange = { newHeight in
            DispatchQueue.main.async {
                // 소수점 차이로 인한 업데이트를 방지하기 위해 이전 값과 비교합니다.
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
        // 폰트가 변경되었을 경우를 대비합니다.
        if uiView.font != font {
            uiView.font = font
        }
        
        if uiView.text != text {
            uiView.text = text
        }
        
        context.coordinator.placeholderLabel?.isHidden = !text.isEmpty
        
        recalculateHeight(view: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func recalculateHeight(view: UITextView) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude))
        DispatchQueue.main.async {
            // 소수점 차이로 인한 의도하지 않은 업데이트 방지를 위해 height를 비교합니다.
            if abs(height - newSize.height) > 1 {
                height = newSize.height
            }
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: _UITextView
        var placeholderLabel: UILabel?
        var onSubmit: (() -> Void)?

        init(_ parent: _UITextView) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if parent.submitOnReturn && text == "\n" {
                parent.onSubmit?()
                return false // 줄 바꿈을 방지합니다.
            }
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            placeholderLabel?.isHidden = !textView.text.isEmpty
            parent.recalculateHeight(view: textView)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isFocused = true
            }
        }
                
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isFocused = false
            }
        }
    }
}
