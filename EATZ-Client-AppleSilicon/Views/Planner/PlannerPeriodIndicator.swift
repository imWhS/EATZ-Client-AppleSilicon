//
//  PlannerPeriodIndicator.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/26/26.
//

import SwiftUI

struct PlannerPeriodIndicator: View {
    let style: PlannerPeriodIndicatorStyle

    let startDate: Date
    let endDate: Date
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            getDateView(date: startDate)
            Image("planner-header-date-arrow")
                .foregroundStyle(Color.init(hex: "7A7A7A"))
            getDateView(date: endDate)
        }
        .padding(6)
    }
    
    private func getDateView(date: Date) -> some View {
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
                .background(style.dateViewBackground)
                .cornerRadius(35)
                .border(color: style.dateViewBorderColor, width: 1, radius: 35)
        )
    }
}

enum PlannerPeriodIndicatorStyle {
    case interactive
    case plain
    
    var dateViewBackground: Color {
        switch self {
        case .interactive: Color.gray8
        case .plain: Color.white
        }
    }
    var dateViewBorderColor: Color {
        switch self {
        case .interactive: Color.gray8
        case .plain: Color.gray15
        }
    }
}
