//
//  RecipeContentImageView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 2/20/26.
//

import SwiftUI
import Kingfisher

struct RecipeContentImageView: View {
    let imageUrl: String?
    
    init(_ imageUrl: String) {
        self.imageUrl = imageUrl
    }
    
    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay (
                KFImage(URL(imageUrlString: imageUrl))
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .clipShape(Rectangle())
    }
}
