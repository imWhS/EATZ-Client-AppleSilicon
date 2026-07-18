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
        Group {
            KFImage(URL(imageUrlString: imageUrl))
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                .ignoresSafeArea()
        }
    }
}
