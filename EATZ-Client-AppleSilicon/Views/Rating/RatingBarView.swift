//
//  RatingBarView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI

struct RatingBarView: View {
    let score: Int
    let count: Int
    let maxCount: Int
    let delay: Double
    
    @State private var animatedRatio: CGFloat = 0
    
    var ratio: CGFloat {
        guard maxCount > 0 else { return 0 }
        return CGFloat(count) / CGFloat(maxCount)
    }
    
    var body: some View {
        HStack(spacing: 5) {
            HStack(spacing: 2) {
                ForEach(0 ..< score, id: \.self) { _ in
                    Image("rating-star")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(Color.black)
                }
                ForEach(0 ..< 5-score, id: \.self) { _ in
                    Image("rating-star")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(Color.init("ECECEC"))
                }
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    Capsule()
                        .fill(Color.init("D69E5C"))
                        .frame(
                            width: animatedRatio * proxy.size.width,
                            height: 8
                        )
                }
                .onAppear {
                    animatedRatio = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            animatedRatio = ratio
                        }
                    }
                }
                .onChange(of: ratio) { newValue in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animatedRatio = newValue
                    }
                }
            }
            .frame(height: 10)
        }
    }
}

#Preview {
    VStack(spacing: 6) {
        RatingBarView(score: 3, count: 3, maxCount: 5, delay: Double(1) * 0.07)
        RatingBarView(score: 3, count: 1, maxCount: 5, delay: Double(2) * 0.07)
        RatingBarView(score: 3, count: 2, maxCount: 5, delay: Double(3) * 0.07)
        RatingBarView(score: 3, count: 4, maxCount: 5, delay: Double(4) * 0.07)
        RatingBarView(score: 3, count: 1, maxCount: 5, delay: Double(5) * 0.07)
    }
}
