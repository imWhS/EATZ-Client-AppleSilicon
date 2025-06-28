//
//  MyRatingItemView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/30/25.
//

import SwiftUI

struct MyRatingItemEmptyView: View {
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        ProfileImageView(imageUrl: nil, size: 32)
                        Text("-")
                            .font(.system(size: 12, weight: .bold))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        RatingStarsView(score: 0, starSize: 18)
                        .frame(height: 32)
                        HStack {
                            Text("-")
                            Text("-점")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .font(.system(size: 12))
                    }
                }
                HorizontalDividerView(horizontalPadding: 0)
                Text("")
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .background(Color.init("F9F9F9"))
            .cornerRadius(24)
            .padding(.horizontal, 20)
        }
    }
}

struct MyRatingItemEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        MyRatingItemEmptyView()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
    }
}
