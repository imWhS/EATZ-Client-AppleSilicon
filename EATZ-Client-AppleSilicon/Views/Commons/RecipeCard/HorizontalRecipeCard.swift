//
//  HorizontalRecipeCard.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/6/26.
//

import SwiftUI
import Kingfisher

struct HorizontalRecipeCard: View {
    let imageUrl: String?
    let size: CGFloat
    let onAction: () -> Void
    
    var body: some View {
        Button(action: onAction) {
            KFImage(URL(imageUrlString: imageUrl))
                .placeholder {
                    ZStack {
                        Rectangle().foregroundStyle(.gray.opacity(0.2))
                        ProgressView()
                    }
                }
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: size)
                .background(Color.white)
                .cornerRadius(12)
        }
        .buttonStyle(ListItemButtonStyle())
    }
}
