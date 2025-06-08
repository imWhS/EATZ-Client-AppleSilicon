//
//  TabLayoutView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 4/12/25.
//

import SwiftUI

struct TabLayoutView<Content: View>: View {
    
    let title: String
    let buttons: [HeaderIconButton]
    
    @ViewBuilder let content: () -> Content
    
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack {
                TabHeaderView(title: MainTabItemsData.explore.title, buttons: buttons)
            }
            
            content()
        }
    }
}
