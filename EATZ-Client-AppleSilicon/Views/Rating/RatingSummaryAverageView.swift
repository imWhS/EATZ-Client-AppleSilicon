//
//  RatingSummaryAverageView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/23/25.
//

import SwiftUI

struct RatingSummaryAverageView: View {
    let averageScore: Double
    let count: Int
    
    var body: some View {
        VStack(spacing: 12) {
            RatingStarsView(score: Int(averageScore))
            HStack {
                Text(String(format: "%.1f", averageScore))
                    .font(.system(size: 64, weight: .bold))
                Group {
                    Text("/")
                    Text("5")
                }
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Color.init("ECECEC"))
            }
            HStack {
                Text("평균 점수")
                    .font(.system(size: 16, weight: .bold))
                DotSeparatorView()
                Text("\(count)개의 평가")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.init("8F8F8F"))
            }
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    RatingSummaryAverageView(averageScore: 3.8, count: 30)
}
