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
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
