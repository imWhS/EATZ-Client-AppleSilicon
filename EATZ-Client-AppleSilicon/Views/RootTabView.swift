//
//  RootTabView.swift
//  AuthInterceptorSample
//
//  Created by 손원희 on 5/15/25.
//

import SwiftUI

struct RootTabView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    @EnvironmentObject var errorManager: ErrorManager
    
    @State var showLogin = false
    
    var body: some View {
        TabView {
            RecipeListView()
                .tabItem { Label(MainTabItemsData.explore.title, systemImage: MainTabItemsData.explore.systemImage) }
            VStack {
                Text("Search View")
                    .font(.title)
                Text("검색")
            }
            .tabItem { Label(MainTabItemsData.search.title, systemImage: MainTabItemsData.search.systemImage) }
            if authManager.isLoggedIn {
                VStack {
                    Text("My Account View")
                        .font(.title)
                    Text("내 계정")
                }
                .tabItem { Label(MainTabItemsData.mypage.title, systemImage: MainTabItemsData.mypage.systemImage) }
            } else {
                VStack {
                    Text("로그아웃 상태입니다.")
                    Button(action: {showLogin = true}) {
                        Text("로그인")
                    }
                }
                .tabItem { Label(MainTabItemsData.hello.title, systemImage: MainTabItemsData.hello.systemImage) }
            }
        }
        .sheetPresenter()
    }
}


