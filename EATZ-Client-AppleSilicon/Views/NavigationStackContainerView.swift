////
////  NavigationStackContainerView.swift
////  EATZ-Client-AppleSilicon
////
////  Created by 손원희 on 6/15/25.
////
//
//import SwiftUI
//
//struct RootNavigationStackContainerView: View {
//    let rootTab: RootTab
//    
//    @State private var path = NavigationPath()
//    
//    @StateObject private var exploreRouter = Router()
//    @StateObject private var plannerRouter = Router()
//    @StateObject private var myAccountRouter = Router()
//    
//    var body: some View {
//        NavigationStack(path: $path) {
//            rootView()
//                .navigationDestination(for: ViewRoute.self) { route in
//                    destinationView(route: route)
//                }
//        }
//    }
//    
//    @ViewBuilder
//    private func rootView() -> some View {
//        switch rootTab {
//        case .explore:
//            ExploreView()
//        case .planner:
//            Text("planner")
//        case .myAccount:
//            VStack {
//                Text("로그아웃 상태입니다!")
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private func destinationView(route: ViewRoute) -> some View {
//        switch route {
//        case .recipe(let id):
//            RecipeView(recipeId: id)
//        case .rating(let recipeId):
////                    Text("Rating View: \(recipeId)")
//            RatingView(recipeId: recipeId)
//        case .profile(let userId):
//            Text("프로필: \(userId)")
//        }
//    }
//}
//
//enum RootTab {
//    case explore, planner, myAccount
//}
