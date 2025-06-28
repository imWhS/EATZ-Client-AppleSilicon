//
//  RatingSummaryAverageView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/23/25.
//

import SwiftUI

struct RatingSummaryAverageView: View {
    let averageScore: Double?
    let count: Int?
    var isPlaceholder: Bool = false
    
    init(averageScore: Double? = nil, count: Int? = nil, isPlaceholder: Bool = false) {
        self.averageScore = averageScore
        self.count = count
        self.isPlaceholder = isPlaceholder
    }
    
    var body: some View {
        let score = isPlaceholder ? 0 : Int(averageScore ?? 0)
        
        VStack(spacing: 12) {
            RatingStarsView(score: score)
            HStack {
                Group {
                    if isPlaceholder {
                        Text("-")
                        .font(.system(size: 64, weight: .light))
                    } else {
                        Text(String(format: "%.1f", averageScore ?? 0.0))
                            .font(.system(size: 64, weight: .bold))
                        Group {
                            Text("/")
                            Text("5")
                        }
                        .font(.system(size: 64, weight: .light))
                        .foregroundStyle(Color.init("ECECEC"))
                    }
                }
            }
            HStack {
                if isPlaceholder {
                    Text("불러오는 중...")
                        .font(.system(size: 16, weight: .bold))
                } else {
                    Text("평균 점수")
                        .font(.system(size: 16, weight: .bold))
                    DotSeparatorView()
                    Text("\(count ?? 0)개의 평가")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color.init("8F8F8F"))
                }
                
            }
        }
        .padding(.vertical, 20)
    }
}

//#Preview {
//    RatingSummaryAverageView(averageScore: 3.8, count: 30)
//}
