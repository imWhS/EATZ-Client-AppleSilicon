//
//  RecipeEditorSectionHeaderView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/12/26.
//

import SwiftUI

struct RecipeEditorSectionHeaderView: View {
    let title: String
    let description: String?
    let hasPadding: Bool
    
    init(title: String, description: String? = nil, hasPadding: Bool = true) {
        self.title = title
        self.description = description
        self.hasPadding = hasPadding
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.black)
                Spacer()
            }
            if let description = description {
                HStack {
                    Text(description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.gray35)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
        }
        .padding(hasPadding ? 20 : 0)
    }
}
