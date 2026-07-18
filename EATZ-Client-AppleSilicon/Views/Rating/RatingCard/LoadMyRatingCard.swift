//
//  LoadMyRatingCard.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/30/25.
//

import SwiftUI

struct LoadMyRatingCard: View {
    var body: some View {
        RatingCard(rating: Rating(), footerView: {})
            .padding(.vertical, 10)
    }
}

struct MyRatingItemEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        LoadMyRatingCard()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color(.systemBackground))
    }
}
