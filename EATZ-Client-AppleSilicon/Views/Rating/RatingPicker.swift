//
//  StarRatingPicker.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/17/25.
//

import SwiftUI

struct RatingPicker: View {
    /// 선택된 별점 (양방향 바인딩)
    @Binding var rating: Int
    
    /// 별 아이콘의 크기
    let starSize: CGFloat = 32
    
    /// 최대 별 개수
    private let maxRating: Int = 5
    
    @State private var tappedIndex: Int? = nil

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maxRating, id: \.self) { index in
                Image("rating-star")
                    .resizable()
                    .frame(width: starSize, height: starSize)
                    .foregroundColor(index <= rating ? Color("D69E5C") : Color("ECECEC"))
                    .scaleEffect(tappedIndex == index ? 0.8 : 1)
                    .onTapGesture {
                        tappedIndex = index
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            rating = index
                            tappedIndex = nil
                        }
                    }
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0),
                        value: tappedIndex
                    )
                    .accessibility(label: Text("별점: \(index)점"))
            }
        }
    }
}

struct StarRatingView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var rating: Int = 3
        var body: some View {
            VStack(spacing: 20) {
                Text("현재 별점: \(rating)")
                RatingPicker(rating: $rating)
            }
            .padding()
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .previewLayout(.sizeThatFits)
    }
}
