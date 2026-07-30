//
//  CalendarPicker.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/25.
//

import SwiftUI

enum CalendarPickerDateSelection: Equatable, Hashable {
    case single(Date)
    case range(startDate: Date, endDate: Date)
    case multiple([Date])
}

struct CalendarPicker: View {
    let mode: CalendarSelectionMode
    let onComplete: (CalendarPickerDateSelection) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDates: [Date] = []
    @State private var currentMonth: Date = Date()
    
    private var previousMonthLabel: String {
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        return previousMonth.formattedMonth
    }
    
    private var nextMonthLabel: String {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        return nextMonth.formattedMonth
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                CalendarSelectionView(
                    currentMonth: $currentMonth,
                    selectedDates: $selectedDates,
                    mode: mode)
                CalendarPickerSummarySection(mode: mode, selectedDates: $selectedDates)
            }
            .navigationTitle("달력")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                dismissToolbarItem
                if mode != .single { doneToolbarItem }
            }
            .onChange(of: selectedDates) {
                if mode == .single {
                    onComplete(makeSelectionResult())
                    dismiss()
                }
            }
        }
    }
    
    private var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("취소") { dismiss() }
        }
    }
    
    private var doneToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("완료") {
                onComplete(makeSelectionResult())
                dismiss()
            }
            .fontWeight(.semibold)
            .tint(Color.accentColor)
            .buttonStyle(.borderedProminent)
            .disabled(selectedDates.isEmpty)
        }
    }
    
    private func makeSelectionResult() -> CalendarPickerDateSelection {
        switch mode {
        case .single:
            return .single(selectedDates.first!)
        case .range:
            let sortedDates = selectedDates.sorted()
            return .range(startDate: sortedDates.first!, endDate: sortedDates.last!)
        case .multiple:
            return .multiple(selectedDates)
        }
    }
}

struct CalendarPickerSummarySection: View {
    let mode: CalendarSelectionMode
    @Binding var selectedDates: [Date]
    
    private var placeholderLabel: String {
        switch mode {
        case .single:
            return "원하는 날짜를 탭하세요."
        case .range:
            return "원하는 날짜 또는 기간의 시작 및 종료 날짜를 탭하세요."
        case .multiple:
            return "원하는 날짜를 모두 탭하세요."
        }
    }
    
    @ViewBuilder
    private var dateSummaryView: some View {
        if selectedDates.isEmpty {
            // 날짜가 단 1개도 선택되어 있지 않을 때
            Text(placeholderLabel)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.secondary)
        } else {
            Group {
                switch mode {
                case .single, .range:
                    let sortedSelectedDates = selectedDates.sorted()
                    HStack(spacing: 8) {
                        if let first = sortedSelectedDates.first {
                            Text(first.formattedYearMonthDay)
                            if let last = sortedSelectedDates.last, 1 < sortedSelectedDates.count {
                                Image("planner-calendar-arrow")
                                Text(last.formattedYearMonthDay)
                            }
                        }
                    }
                    
                case .multiple:
                    if let firstTappedDate = selectedDates.first {
                        if selectedDates.count == 1 {
                            // 선택된 날짜가 1개일 때
                            Text(firstTappedDate.formattedYearMonthDay)
                        } else {
                            // 선택된 날짜가 2개 이상일 때
                            let selectedDatesCount = selectedDates.count
                            Text("\(firstTappedDate.formattedYearMonthDay) 및 \(selectedDatesCount)개의 날짜")
                        }
                    }
                }
            }
            .font(.system(size: 17, weight: .semibold))
        }
    }
    
    var body: some View {
        HStack {
            dateSummaryView
            if mode == .multiple && !selectedDates.isEmpty {
                Spacer()
                Button {
                    selectedDates.removeAll()
                } label: {
                    Text("초기화")
                }
                .buttonStyle(SmallRoundedButtonStyle(type: .secondary))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 30)
        .padding(20)
        .background(Color.backgroundPrimary)
    }
}
