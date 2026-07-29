//
//  RatingCardContentView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/19/25.
//

import SwiftUI

struct RatingCardContentView: View {
    let content: String?
    
    init(content: String? = nil) {
        self.content = content
    }
    
    var body: some View {
        if let content = content, !content.isEmpty {
            VStack(spacing: 16) {
                HorizontalDivider(padding: 0)
                Text(content)
                    .font(.system(size: 17, weight: .medium))
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
        } else {
            EmptyView()
        }
    }
}
