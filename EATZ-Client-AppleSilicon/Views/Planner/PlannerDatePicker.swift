//
//  PlannerDatePicker.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/12/25.
//

import SwiftUI

/// 원하는 날짜를 선택해, 특정 레시피를 플래너의 해당 날짜에 플랜으로 추가하는 뷰입니다.
struct PlannerDatePicker: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PlannerDatePickerViewModel
    private let onComplete: (() -> Void)?
    
    init(for recipeId: Int64, onComplete: (() -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: PlannerDatePickerViewModel(recipeId: recipeId))
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationStack {
            viewStateContent
                .navigationTitle("플래너에 추가")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { dismissToolbarItem }
        }
            .alert(item: $viewModel.alert) { $0.alert }
            .task {
                viewModel.setCompleteActions(onDismiss: dismiss.callAsFunction, onComplete: onComplete)
                viewModel.prepareDataIfNeeded()
            }
            .onChange(of: viewModel.currentMonth) { _, currentMonth in
                viewModel.loadPlannedDates(for: currentMonth)
            }
            .onChange(of: viewModel.selectedDates) { _, selectedDates in
                guard let selectedDate = selectedDates.first else { return }
                viewModel.addToPlanner(on: selectedDate)
            }
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("취소") { dismiss() }
        }
    }
    
    @ViewBuilder
    private var viewStateContent: some View {
        Group {
            switch viewModel.viewState {
            case .loading: LoadingCurtain(title: "회원님의 모든 플랜을 불러오고 있어요...")
            case .loaded: mainContent
            case .unauthorized: CommonUnauthorizedStateView()
            case .error(let message): ErrorCurtain(message, onRetry: viewModel.prepareDataIfNeeded)
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            header
            CalendarSelectionView(
                currentMonth: $viewModel.currentMonth,
                selectedDates: $viewModel.selectedDates,
                mode: .single,
                disabledDates: viewModel.plannedDates
            )
        }
    }
    
    private var header: some View {
        VStack(spacing: 10) {
            Text("언제 요리할 계획인가요?")
                .font(.system(size: 30, weight: .bold))
            Text("레시피를 플래너에 추가할 날짜를 탭하세요. 레시피가 해당 날짜의 플랜으로 추가돼요.")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.gray35)
        }
        .padding(.vertical, 12)
    }
}

#if DEBUG
#Preview {
    struct PreviewWrapper: View {
        @State private var isSheetPresented = false
        
        var body: some View {
            VStack {
                Button("플래너에 추가 시트 열기") {
                    isSheetPresented = true
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                // isSheetPresented가 true가 되면 이 뷰가 시트로 나타나요.
                PlannerDatePicker(for: 1) {
                    
                }
            }
        }
    }
    
    // 프리뷰에서 컨테이너 뷰를 표시합니다.
    return PreviewWrapper()
}
#endif
