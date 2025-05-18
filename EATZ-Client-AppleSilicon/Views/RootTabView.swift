//
//  RootTabView.swift
//  AuthInterceptorSample
//
//  Created by 손원희 on 5/15/25.
//

import SwiftUI

struct RootTabView: View {
    
    var body: some View {
        TabView {
            RecipeListView()
                .tabItem { Label("레시피", systemImage: "book") }
            LogInView()
                .tabItem { Label("마이페이지", systemImage: "person.crop.circle") }
        }
    }
}


