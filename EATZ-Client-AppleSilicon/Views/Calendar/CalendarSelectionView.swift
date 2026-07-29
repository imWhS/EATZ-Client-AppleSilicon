//
//  CalendarSelectionView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 1/20/26.
//

import SwiftUI

struct CalendarSelectionView: View {
    @Binding private var currentMonth: Date
    @Binding private var selectedDates: [Date]
    
    private let mode: CalendarSelectionMode
    private let disabledDates: Set<Date>
    
    init(currentMonth: Binding<Date>,
         selectedDates: Binding<[Date]>,
         mode: CalendarSelectionMode,
         disabledDates: Set<Date> = []) {
        self._currentMonth = currentMonth
        self._selectedDates = selectedDates
        self.mode = mode
        self.disabledDates = disabledDates
    }
    
    var body: some View {
        VStack(spacing: 12) {
            CalendarHeaderView($currentMonth, onChangeMonth: handleChangeMonth)
            CalendarWeekdaysView()
            CalendarView($selectedDates, $currentMonth, mode, disabledDates)
        }
    }
    
    private func handleChangeMonth(to direction: CalendarSelectionChangeMonthDirection) {
        let offset: Int
        
        switch direction {
        case .previous: offset = -1
        case .next: offset = 1
        }
        
        if let month = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = month
        }
    }
}

private struct CalendarWeekdaysView: View {
    private var weekdaySymbols = EatzDateTimeFormatters.veryShortWeekdaySymbols
    
    var body: some View {
        VStack {
            HStack {
                ForEach(weekdaySymbols.indices, id: \.self) { index in
                    Text(weekdaySymbols[index])
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.gray35)
                }
            }
            .padding(.horizontal, 20)
            HorizontalDivider()
        }
    }
}

private struct CalendarHeaderView: View {
    @Binding var currentMonth: Date
    let onChangeMonth: (CalendarSelectionChangeMonthDirection) -> Void
    
    init(_ currentMonth: Binding<Date>, onChangeMonth: @escaping (CalendarSelectionChangeMonthDirection) -> Void) {
        self._currentMonth = currentMonth
        self.onChangeMonth = onChangeMonth
    }
    
    private var previousMonthLabel: String {
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        return previousMonth.formattedMonth
    }
    
    private var nextMonthLabel: String {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        return nextMonth.formattedMonth
    }
    
    var body: some View {
        HStack {
            Text(currentMonth.formattedMonth)
                .font(.system(size: 22, weight: .semibold))
            Spacer()
            HStack(spacing: 8) {
                changeMonthButton(direction: .previous, text: previousMonthLabel)
                changeMonthButton(direction: .next, text: nextMonthLabel)
            }
        }
        .padding(20)
    }
    
    private func changeMonthButton(direction: CalendarSelectionChangeMonthDirection, text: String) -> some View {
        Button {
            onChangeMonth(direction)
        } label: {
            HStack(spacing: 4) {
                if direction == .previous {
                    Image(systemName: "chevron.left")
                    Text(text)
                } else {
                    Text(text)
                    Image(systemName: "chevron.right")
                }
            }
        }
        .buttonStyle(SmallRoundedButtonStyle(type: .secondary))
    }
}

private enum CalendarSelectionChangeMonthDirection {
    case previous, next
}
