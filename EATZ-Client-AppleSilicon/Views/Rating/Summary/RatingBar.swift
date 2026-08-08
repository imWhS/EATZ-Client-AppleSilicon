//
//  RatingBar.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/24/25.
//

import SwiftUI

struct RatingBar: View {
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
                        .foregroundStyle(Color.buttonSecondary)
                }
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.buttonSecondary)
                        .frame(height: 8)
                    Capsule()
                        .fill(Color.rating)
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
                .onChange(of: ratio) { _, ratio in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animatedRatio = ratio
                    }
                }
            }
            .frame(height: 10)
        }
    }
}

#Preview {
    VStack(spacing: 6) {
        RatingBar(score: 3, count: 3, maxCount: 5, delay: Double(1) * 0.07)
        RatingBar(score: 3, count: 1, maxCount: 5, delay: Double(2) * 0.07)
        RatingBar(score: 3, count: 2, maxCount: 5, delay: Double(3) * 0.07)
        RatingBar(score: 3, count: 4, maxCount: 5, delay: Double(4) * 0.07)
        RatingBar(score: 3, count: 1, maxCount: 5, delay: Double(5) * 0.07)
    }
}
