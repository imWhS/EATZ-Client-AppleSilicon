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
    
    @StateObject private var exploreRouter = Router()
    @StateObject private var plannerRouter = Router()
    @StateObject private var myAccountRouter = Router()
    
    var body: some View {
        TabView {
            ExploreView()
            .tabItem { Label(MainTabItemsData.explore.title, systemImage: MainTabItemsData.explore.systemImage) }
            .environmentObject(exploreRouter)
            
            VStack {
                Text("Planner View")
                    .font(.title)
                Text("플래너")
            }
            .tabItem { Label(MainTabItemsData.planner.title, systemImage: MainTabItemsData.planner.systemImage) }
            if authManager.isLoggedIn {
                VStack {
                    Text("My Account View")
                        .font(.title)
                    Text("내 계정")
                }
                .tabItem { Label(MainTabItemsData.myAccount.title, systemImage: MainTabItemsData.myAccount.systemImage) }
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
        .fullScreenCover(item: $authManager.isRequiredAuth, onDismiss: {
            authManager.handleAuthDismiss()
        }) { context in
            AuthView(context: context)
        }
//        .fullScreenCover(item: $authManager.isRequiredAuth, onDismiss: {
//            authManager.isRequiredAuth?.onDismiss!()
//
//            authManager.isRequiredAuth = nil
//            print("PRESENTDBG - root tab view - bye")
//        }) { context in
//            AuthView(context: context)
//        }
    }
}


