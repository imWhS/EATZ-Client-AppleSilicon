//
//  HeaderIconButton.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/6/25.
//

import SwiftUI

struct HeaderIconButton: View {
    
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(HeaderIconButtonStyle())
    }
}

#Preview {
    HeaderIconButton(title: "카테고리") {
        print("test")
    }
}
