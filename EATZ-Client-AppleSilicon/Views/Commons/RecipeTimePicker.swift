import SwiftUI


/// 레시피의 요리 시간과 준비 시간을 선택할 수 있는 뷰입니다.
///
/// Sheet 타입의 모달 형태로 present해야 합니다.
/// UI 표시를 위한 상태를 제외하고, 모든 시간 값의 단위로 '분'을 사용합니다.
/// 하위 뷰인 `TimePickerView`를 통해 시간을 설정할 수 있습니다.
 
struct RecipeTimePicker: View {
    @Environment(\.dismiss) private var dismiss
    
    /// 현재 UI에 표시되는 요리 시간 상태입니다.
    ///
    /// `TimePickerView`는 요리 시간을 시간, 분 단위 별 picker로 선택하는 구조입니다. 해당 뷰의 구조에 맞춰 binding하기 위해, 상태를 `(시간, 분)` 튜플로 묶어 관리합니다.
    @State private var cookingDurationTime: (h: Int, m: Int)
    
    /// 현재 UI에 표시되는 준비 시간 상태입니다.
    ///
    /// `TimePickerView`는 준비 시간을 시간, 분 단위 별 picker로 선택하는 구조입니다. 해당 뷰의 구조에 맞춰 binding하기 위해, 상태를 `(시간, 분)` 튜플로 묶어 관리합니다.
    @State private var prepDurationTime: (h: Int, m: Int)
    
    /// 선택 완료 시 호출됩니다.
    ///
    /// 요리 시간과 준비 시간을 각각 '분' 단위로 반환합니다. 준비 시간은 optional하기 때문에, 사용자가 준비 시간을 선택하지 않은 경우에는 `nil`을 반환합니다.
    let onComplete: (_ cookingTime: Int, _ prepTime: Int?) -> Void
    
    /// 초기화 메서드 또는 `TimePickerView`를 통해 설정된 `cookingTime` 튜플을 '초' 단위로 변환한 시간입니다.
    ///
    /// 요리 시간의 실질적인 데이터 소스입니다.
    /// 뷰 내부에서 시간을 계산하거나, 시간의 유효성을 검사하거나, 시간을 다양한 단위로 표시하는 등의 로직 처리를 편리하게 하기 위해 사용합니다.
    private var cookingTime: Int {
        (cookingDurationTime.h * 3600) + (cookingDurationTime.m * 60)
    }
        
    /// 초기화 메서드 또는 `TimePickerView`를 통해 설정된 `prepTime` 튜플을 '초' 단위로 변환한 시간입니다.
    ///
    /// 준비 시간의 실질적인 데이터 소스입니다.
    /// 뷰 내부에서 시간을 계산하거나, 시간의 유효성을 검사하거나, 시간을 다양한 단위로 표시하는 등의 로직 처리를 편리하게 하기 위해 사용합니다.
    private var prepTime: Int {
        (prepDurationTime.h * 3600) + (prepDurationTime.m * 60)
    }
    
    /// 현재 요리 시간의 0 여부를 확인합니다.
    private var isCookingTimeZero: Bool {
        cookingTime == 0
    }
    
    private var totalTimeDetailLabel: String {
        let cookingTimeLabel = getFormattedTime(for: cookingTime)
        let prepTimeLabel = getFormattedTime(for: prepTime)
        return "요리 시간 \(cookingTimeLabel) + 준비 시간 \(prepTimeLabel)"
    }
    
    private var totalTimeLabel: String {
        let totalTime = cookingTime + prepTime
        return getFormattedTime(for: totalTime)
    }
    
    /// '분' 단위의 시간을 '1시간 30분' 형태의 문자열로 변환합니다.
    private func getFormattedTime(for seconds: Int) -> String {
        return EatzDurationFormatter.seconds(from: seconds) ?? "0분"
    }
    
    /// 뷰의 주요 프로퍼티 값을 초기화하고, 해당 값을 UI에 표시하기 위한 상태로 불러옵니다.
    ///
    /// - Parameters:
    ///     - `cookingTime`: 초기 값으로 표시할 요리 시간입니다. `TimePickerView`를 통해 초기 UI에 표시되며, 뷰 내부에서 시간 관련 초기 로직 처리에 사용합니다. '초' 단위를 사용합니다.
    ///     - `prepTime`: 초기 값으로 표시할 준비 시간입니다. `TimePickerView`를 통해 초기 UI에 표시되며, 뷰 내부에서 시간 관련 초기 로직 처리에 사용합니다. '초' 단위를 사용합니다.
    ///     - `onComplete`: 선택 완료 후, 뷰가 dismiss 될 때 실행할 동작입니다.
    init(cookingTime: Int?, prepTime: Int?, onComplete: @escaping (_ cookingTime: Int, _ prepTime: Int?) -> Void) {
        self.onComplete = onComplete
        
        // 요리 시간을 picker에서 사용하는 `(시간, 분)` 튜플 타입으로 변환 후, `cookingTime`의 초기 값으로 설정합니다.
        _cookingDurationTime = State(initialValue: Self.toMinutesAndSeconds(from: cookingTime))
        
        // 준비 시간을 picker에서 사용하는 `(시간, 분)` 튜플 타입으로 변환 후, `prepTime`의 초기 값으로 설정합니다.
        _prepDurationTime = State(initialValue: Self.toMinutesAndSeconds(from: prepTime))
    }
    
    var body: some View {
        NavigationStack {
            cookingTimePickerView
                .navigationDestination(for: String.self) { _ in
                    prepTimePickerView
                }
        }
        .presentationDetents([.height(350)])
    }
    
    private var cookingTimePickerView: some View {
        VStack(spacing: 0) {
            TimePickerView(
                hours: $cookingDurationTime.h,
                minutes: $cookingDurationTime.m
            )
            Spacer()
            prepTimeLinkButton
        }
        .navigationTitle("요리 시간")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            dismissToolbarItem
            doneToolbarItem
        }
    }
    
    private var prepTimeLinkButton: some View {
        NavigationLink(value: "prep") {
            HStack {
                Text(prepTime == 0 ? "준비 시간 설정" : "준비 시간 편집")
                Image("arrow-right-14")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(CapsuleLargeButtonStyle(appearance: .secondary))
        .padding()
        .opacity(isCookingTimeZero ? 0.5 : 1)
        .disabled(isCookingTimeZero)
    }
    
    private var prepTimePickerSummaryCardView: some View {
        VStack(spacing: 4) {
            HStack {
                Text("소요 시간 \(totalTimeLabel)")
            }
            Text(totalTimeDetailLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.gray50)
        }
        .font(Font.system(size: 17, weight: .semibold))
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .background(Color.clear)
        .cornerRadius(12)
        .padding()
    }
    
    private var prepTimePickerView: some View {
        VStack(spacing: 0) {
            TimePickerView(
                hours: $prepDurationTime.h,
                minutes: $prepDurationTime.m
            )
            Spacer()
            HorizontalDivider()
            prepTimePickerSummaryCardView
        }
        .background(Color.clear)
        .navigationTitle("준비 시간")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            doneToolbarItem
        }
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.black)
            }
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("완료") {
                onComplete(cookingTime, prepTime)
                dismiss()
            }
            .fontWeight(.semibold)
            .tint(Color.accentColor)
            .buttonStyle(.borderedProminent)
            .disabled(isCookingTimeZero)
        }
    }
    
    /// '초' 단위의 시간을 시간(h)과 분(m)의 구성 요소로 분해합니다.
    /// - Parameter seconds: 전체 '초' 단위 시간
    /// - Returns: (시간, 분) 형태의 튜플
    private static func toMinutesAndSeconds(from seconds: Int?) -> (h: Int, m: Int) {
        let seconds = seconds ?? 0
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        return (h, m)
    }
}
