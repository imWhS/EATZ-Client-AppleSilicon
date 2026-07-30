//
//  ServingsPickerView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/3/25.
//

import SwiftUI

/**
 레시피의 제공량을 선택할 수 있는 뷰입니다.
 
 Sheet 타입의 모달 형태로 present해야 합니다.
 UI 표시를 위한 상태를 포함한 모든 제공량 값의 단위로 '인'을 사용합니다.
 하위 뷰인 `servingsPickerView`를 통해 시간을 설정할 수 있습니다.
 */
struct ServingsPicker: View {
    @Environment(\.dismiss) private var dismiss

    /// 현재 UI에 표시되는 제공량 상태입니다.
    @State private var servings: Int
    
    private var isServingsZero: Bool {
        servings == 0
    }
    
    /// 선택 완료 시 호출됩니다.
    ///
    /// 제공량을 '인' 단위로 반환합니다. 사용자가 제공량을 설정하지 않은 경우에는 `nil`을 반환합니다.
    let onComplete: (_ servings: Int?) -> Void
    
    /// 뷰의 주요 프로퍼티 값을 초기화하고, 해당 값을 UI에 표시하기 위한 상태로 불러옵니다.
    ///
    /// - Parameters:
    ///     - `servings`: 초기 값으로 표시할 제공량입니다. `servingsPickerView`를 통해 초기 UI에 표시되며, 뷰 내부에서 제공량 관련 초기 로직 처리에 사용합니다. '인' 단위를 사용합니다.
    ///     - `onComplete`: 선택 완료 후, 뷰가 dismiss 될 때 실행할 동작입니다.
    init(servings: Int?, onComplete: @escaping (_ servings: Int?) -> Void) {
        self.onComplete = onComplete
        
        let initialServings = servings ?? 0
        _servings = State(initialValue: initialServings)
    }

    var body: some View {
        NavigationStack {
            containerView
        }
        .presentationDetents([.height(350)])
    }
    
    private var containerView: some View {
        VStack(spacing: 0) {
            servingsPickerView
            Spacer()
            
            Button(action: {
                onComplete(nil)
                dismiss()
            }) {
                Text("설정 안 함")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BigRoundedButtonStyle(type: .secondary))
            .padding()
        }
        .navigationTitle("제공량")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            cancelToolbarItem
            doneToolbarItem
        }
    }
    
    private var cancelToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("완료") {
                onComplete(servings)
                dismiss()
            }
            .fontWeight(.semibold)
            .tint(Color.accentColor)
            .buttonStyle(.borderedProminent)
            .disabled(isServingsZero)
        }
    }
    
    private var servingsPickerView: some View {
        HStack {
            Picker("제공량", selection: $servings) {
                ForEach(0 ..< 20) { Text("\($0)인").tag($0) }
            }
            .pickerStyle(.wheel)
        }
    }
}

struct TodayServingsPickerView_Preview_Wrapper: View {
    @State private var servings: Int = 1
    
    var body: some View {
        VStack {}
            .sheet(isPresented: .constant(true)) {
                ServingsPicker(servings: 100) { servings in
                    print("제공량: \(servings)")
                }
            }
    }
}

#Preview {
    TodayServingsPickerView_Preview_Wrapper()
}
