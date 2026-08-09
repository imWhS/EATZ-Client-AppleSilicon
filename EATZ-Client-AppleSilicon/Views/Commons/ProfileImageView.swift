//
//  ProfileImageView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/18/25.
//

import SwiftUI
import Kingfisher

struct ProfileImageView: View {
    let imageUrl: String?
    let size: CGFloat
    
    init(_ imageUrl: String?, size: CGFloat) {
        self.imageUrl = imageUrl
        self.size = size
    }
    
    var body: some View {
        KFImage(URL(imageUrlString: imageUrl))
            .placeholder {
                Image("profile")
                    .resizable()
                    .foregroundStyle(Color.gray20)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .contentShape(Circle())
    }
}

#Preview {
    VStack {
        ProfileImageView("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLiKmxv4M0fkn7aA-Sh4V1kA0LO_KgAQp9NHsaEQ6F918AGzmeT8qdhZc0lpM3jhy2u6c&usqp=CAU", size: 28)
        ProfileImageView("", size: 28)
    }
}
