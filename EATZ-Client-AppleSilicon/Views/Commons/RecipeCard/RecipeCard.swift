//
//  RecipeCard.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/6/26.
//

import SwiftUI
import Kingfisher

struct RecipeCard: View {
    let imageUrl: String?
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            KFImage(URL(imageUrlString: imageUrl))
                .placeholder {
                    ZStack {
                        Rectangle().foregroundStyle(.gray.opacity(0.2))
                        ProgressView()
                    }
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .background(Color.white)
                .cornerRadius(12)
                .contentShape(Rectangle())
                .clipped()
        }
        .buttonStyle(ListItemButtonStyle())
    }
}
