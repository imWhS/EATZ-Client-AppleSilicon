//
//  TimePickerView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/3/25.
//

import SwiftUI

struct TimePickerView: View {
    @Binding var hours: Int
    @Binding var minutes: Int

    var body: some View {
        HStack {
            Picker("시간", selection: $hours) {
                ForEach(0 ..< 24) { Text("\($0)시간").tag($0) }
            }
            .pickerStyle(.wheel)
            
            Picker("분", selection: $minutes) {
                ForEach(0 ..< 60) { Text("\($0)분").tag($0) }
            }
            .pickerStyle(.wheel)
        }
    }
}
