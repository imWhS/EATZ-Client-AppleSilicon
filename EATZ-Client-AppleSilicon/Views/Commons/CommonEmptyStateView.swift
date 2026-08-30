//
//  CommonEmptyStateView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/9/26.
//

import SwiftUI

struct CommonEmptyStateView: View {
    var title: String
    var description: String?
    var imageAssetName: String?
    
    init(title: String, _ description: String? = nil, _ imageAssetName: String? = nil) {
        self.title = title
        self.description = description
        self.imageAssetName = imageAssetName
    }
    
    var body: some View {
        Curtain(
            title: title,
            description: description ?? "",
            header: {
                Image(imageAssetName ?? "info-40")
                    .foregroundStyle(Color.gray15)
            }
        )
    }
}
