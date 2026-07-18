//
//  SortTypePicker.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/17/25.
//

import SwiftUI

protocol Sortable: Identifiable, Hashable {
    /// 뷰를 통해 보여질 문자열입니다.
    var displayName: String { get }
}

struct SortPicker<Sort: Sortable>: View {
    @Binding var sort: Sort
    var selectableSorts: [Sort]
    let isDisabled: Bool
    
    var body: some View {
        HStack {
            Menu {
                Picker("정렬 기준", selection: $sort) {
                    ForEach(selectableSorts) { Text($0.displayName).tag($0) }
                }
            } label: {
                HStack(spacing: 4) {
                    Image("sort")
                    Text("정렬 기준")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(SmallBorderlessButtonStyle())
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.2 : 1.0)
        }
        .padding(.trailing, 12)
    }
}
