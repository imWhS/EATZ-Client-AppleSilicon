//
//  TabLayoutView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/12/25.
//

import SwiftUI

struct TabLayoutView<Content: View>: View {
    let mainTabItems: MainTabItems
    let buttons: [HeaderIconButton]
    
    @ViewBuilder let contentView: () -> Content
    
    var body: some View {
        ScrollView {
            VStack {
                TabHeaderView(title: mainTabItems.title, buttons: buttons)
                contentView()
            }
        }
        .coordinateSpace(name: "scroll")
    }
}
