//
//  RecipeEditorImageSectionContainer.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/6/26.
//

import SwiftUI

struct RecipeEditorImageSectionContainer<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.init(hex: "F9F9F9"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
