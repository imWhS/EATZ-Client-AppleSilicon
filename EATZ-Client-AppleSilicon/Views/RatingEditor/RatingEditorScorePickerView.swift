//
//  RatingEditorScorePickerView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/17/25.
//

import SwiftUI

struct RatingEditorScorePickerView: View {
    /// 선택된 별점
    @Binding var score: Int
    
    /// 별 아이콘의 크기
    let starSize: CGFloat = 32
    
    /// 최대 별 개수
    private let maxRating: Int = 5
    
    @State private var tappedIndex: Int?

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maxRating, id: \.self) { index in
                Image("rating-star")
                    .resizable()
                    .frame(width: starSize, height: starSize)
                    .foregroundStyle(index <= score ? Color.rating : Color.gray8)
                    .scaleEffect(tappedIndex == index ? 0.8 : 1)
                    .onTapGesture {
                        tappedIndex = index
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            score = index
                            tappedIndex = nil
                        }
                    }
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0),
                        value: tappedIndex
                    )
                    .accessibility(label: Text("점수: \(index)점"))
            }
        }
    }
}
