//
//  RecipeItemThumbnailView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/21/25.
//

import SwiftUI
import Kingfisher

struct RecipeItemThumbnail: View {
    let id: Int64
    let isSaved: Bool
    let imageUrlString: String?
    let width: CGFloat
    let onSaveTapped: (Int64) -> Void
    
    private var imageUrl: URL? {
        URL(imageUrlString: imageUrlString)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            imageView
            Button(action: {
                onSaveTapped(id)
            }) {
                VStack {
                    Image(isSaved ? "recipe-list-item-save-filled" : "recipe-list-item-save-stroked")
                        .foregroundStyle(Color.white)
                        .padding(8)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 1)
                }
                .frame(width: 28, height: 28)
                .padding(4)
            }
            .buttonStyle(ScaleDownButtonStyle(cornerRadius: 12))
            .padding(8)
        }
    }
    
    @ViewBuilder
    private var imageView: some View {
        KFImage(imageUrl)
            .placeholder {
                ZStack {
                    Rectangle().foregroundStyle(.gray.opacity(0.2))
                    ProgressView()
                }
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: width)
            .contentShape(Rectangle())
            .clipped()
    }
}
