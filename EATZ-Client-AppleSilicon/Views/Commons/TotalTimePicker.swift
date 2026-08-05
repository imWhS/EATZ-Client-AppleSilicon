//
//  CookableTotalTimePickerView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/3/25.
//

import SwiftUI

/**
 레시피의 소요 시간을 선택할 수 있는 뷰입니다.
 
 소요 시간은 요리 시간과 준비 시간을 합친 시간입니다.
 Sheet 타입의 모달 형태로 present해야 합니다.
 UI 표시를 위한 상태를 제외하고, 모든 시간 값의 단위로 '분'을 사용합니다.
 하위 뷰인 `TimePickerView`를 통해 시간을 설정할 수 있습니다.
 */
struct TotalTimePicker: View {
    @Environment(\.dismiss) private var dismiss

    /// 현재 UI에 표시되는 소요 시간 상태입니다.
    ///
    /// `TimePickerView`는 소요 시간을 시간, 분 단위 별 picker로 선택하는 구조입니다. 해당 뷰의 구조에 맞춰 binding하기 위해, 상태를 `(시간, 분)` 튜플로 묶어 관리합니다.
    @State private var totalTime: (h: Int, m: Int)
    
    /// 초기화 메서드 또는 `TimePickerView`를 통해 설정된 `totalTime` 튜플을 '분' 단위로 변환한 시간입니다.
    ///
    /// 소요 시간의 실질적인 데이터 소스입니다.
    /// 뷰 내부에서 시간을 계산하거나, 시간의 유효성을 검사하거나, 시간을 다양한 단위로 표시하는 등의 로직 처리를 편리하게 하기 위해 사용합니다.
    private var totalTimeInMinutes: Int {
        self.totalTime.h * 60 + self.totalTime.m
    }
    
    /// 현재 소요 시간의 0 여부를 확인합니다.
    private var isTotalTimeZero: Bool {
        totalTimeInMinutes == 0
    }
    
    /// 선택 완료 시 호출됩니다.
    ///
    /// 소요 시간을 '분' 단위로 반환합니다. 사용자가 소요 시간을 설정하지 않은 경우에는 `nil`을 반환합니다.
    let onComplete: (_ totalTime: Int?) -> Void
    
    /// 뷰의 주요 프로퍼티 값을 초기화하고, 해당 값을 UI에 표시하기 위한 상태로 불러옵니다.
    ///
    /// - Parameters:
    ///     - `totalTimeInMinutes`: 초기 값으로 표시할 소요 시간입니다. `TimePickerView`를 통해 초기 UI에 표시되며, 뷰 내부에서 시간 관련 초기 로직 처리에 사용합니다. '분' 단위를 사용합니다.
    ///     - `onComplete`: 선택 완료 후, 뷰가 dismiss 될 때 실행할 동작입니다.
    init(totalTimeInMinutes: Int?, onComplete: @escaping (_ totalTime: Int?) -> Void) {
        self.onComplete = onComplete
        
        // 소요 시간을 picker에서도 사용할 수 있는 `(시간, 분)` 튜플 타입으로 변환 후, `totalTime`의 초기 값으로 설정합니다.
        let initialTotalTimeInMinutes = totalTimeInMinutes ?? 0
        _totalTime = State(initialValue: (initialTotalTimeInMinutes / 60, initialTotalTimeInMinutes % 60))
    }

    var body: some View {
        NavigationStack {
            pickerView
        }
        .presentationDetents([.height(350)])
    }
    
    private var pickerView: some View {
        VStack(spacing: 0) {
            TimePickerView(
                hours: $totalTime.h,
                minutes: $totalTime.m)
            Spacer()
            Text("소요 시간은 요리 시간에 준비 시간을 더한 시간이에요.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gray50)
            
            Button(action: {
                onComplete(nil)
                dismiss()
            }) {
                Text("설정 안 함")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(CapsuleLargeButtonStyle(appearance: .secondary))
            .padding()
        }
        .navigationTitle("소요 시간")
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
                onComplete(totalTimeInMinutes)
                dismiss()
            }
            .fontWeight(.semibold)
            .tint(Color.accentColor)
            .buttonStyle(.borderedProminent)
            .disabled(isTotalTimeZero)
        }
    }
}

struct TodayTotalTimePickerView_Preview_Wrapper: View {
    @State private var totalTime: Int = 100
    
    var body: some View {
        VStack {}
            .sheet(isPresented: .constant(true)) {
                TotalTimePicker(totalTimeInMinutes: 100) { totalTime in
                    print("시간: \(totalTime)")
                }
            }
    }
}

#Preview {
    TodayTotalTimePickerView_Preview_Wrapper()
}
