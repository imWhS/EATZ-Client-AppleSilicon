//
//  RecipeEditorImageView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 2/20/26.
//

import SwiftUI
import Kingfisher

struct RecipeEditorImageView: View {
    let uiImage: UIImage?
    let imageUrl: String?
    
    init (_ uiImage: UIImage) {
        self.uiImage = uiImage
        self.imageUrl = nil
    }
    
    init(_ imageUrl: String) {
        self.uiImage = nil
        self.imageUrl = imageUrl
    }
    
    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .background(Color.backgroundPrimary)
            .overlay (
                Group {
                    if let uiImage = uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        KFImage(URL(imageUrlString: imageUrl))
                            .placeholder {
                                ProgressView("대표 사진을 불러오고 있어요...")
                                    .foregroundStyle(Color.gray20)
                            }
                            .resizable()
                            .scaledToFill()
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
