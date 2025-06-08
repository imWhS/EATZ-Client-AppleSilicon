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
    
    var body: some View {
        if let imageUrl = imageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .placeholder {
                    Circle()
                        .fill(Color.white)
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .contentShape(Circle())
        } else {
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .contentShape(Circle())
        }
        
    }
}

#Preview {
    ProfileImageView(imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQLiKmxv4M0fkn7aA-Sh4V1kA0LO_KgAQp9NHsaEQ6F918AGzmeT8qdhZc0lpM3jhy2u6c&usqp=CAU", size: 28)
}
