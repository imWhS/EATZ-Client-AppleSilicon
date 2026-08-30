//
//  PlannerHeader.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/24/25.
//

import SwiftUI

struct PlannerHeader: View {
    let dateRange: (startDate: Date, endDate: Date)?
    let isDisabled: Bool
    let onShowCalendar: (() -> Void)?
    
    init(
        dateRange: (startDate: Date, endDate: Date),
        isDisabled: Bool = false,
        onShowCalendar: (() -> Void)? = nil) {
        self.dateRange = dateRange
        self.isDisabled = isDisabled
        self.onShowCalendar = onShowCalendar
    }
    
    init(
        dateRange: (startDate: Date, endDate: Date),
        isDisabled: Bool = false) {
        self.dateRange = dateRange
        self.isDisabled = isDisabled
        self.onShowCalendar = {}
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if let range = dateRange {
                dateRangeView(range.startDate, range.endDate)
                    .disabled(isDisabled)
                    .opacity(isDisabled ? 0.5 : 1)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(headerBackgroundGradient)
    }
    
    private var headerBackgroundGradient: LinearGradient {
        let gradientColor = Color.backgroundPrimary
        
        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: gradientColor, location: 0.0),
                .init(color: gradientColor, location: 0.25),
                .init(color: gradientColor.opacity(0), location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func dateRangeView(_ startDate: Date, _ endDate: Date) -> some View {
        VStack(spacing: 8) {
            Button(action: onShowCalendar ?? {}) {
                PlannerPeriodIndicator(style: .interactive, startDate: startDate, endDate: endDate)
            }
            .buttonStyle(PlannerHeaderDateViewButtonStyle())
            
            HStack(spacing: 4) {
                Text("달력 보기")
                    .font(.system(size: 12, weight:. bold))
                Image("arrow-down-5.6")
            }
            .foregroundStyle(isDisabled ? Color.gray25 : Color.accentColor)
        }
    }
    
    private func singleDateView(date: Date) -> some View {
        let uiFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        let capHeight = uiFont.capHeight // 대문자 'H'의 높이. 숫자 높이와 거의 같습니다.
        let descender = uiFont.descender // 베이스라인 아래로 내려가는 공간의 크기 (음수 값).
        
        return (
            VStack(spacing: 8) {
                Text(EatzDateTimeFormatters.monthWithUnit.string(from: date))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.black)
                Text(EatzDateTimeFormatters.day.string(from: date))
                    .font(.system(size: 24, weight: .bold))
                    .baselineOffset(-descender)
                    .frame(height: capHeight)
                    .foregroundStyle(Color.black)
            }
                .frame(width: 70, height: 70)
                .background(Color.gray8)
                .cornerRadius(35)
        )
    }
}
