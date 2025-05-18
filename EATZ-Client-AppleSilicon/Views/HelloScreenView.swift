//
//  MyPageView.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/10/25.
//

import SwiftUI

struct HelloScreenView: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            Text("Hello Screen View")
            Button(action: {
                print("이메일로 계속하기 화면을 불러올게요")
                AuthManager.shared.presentSignInView()
            }) {
                Text("이메일로 계속하기")
            }
        }
        
    }
}

#Preview {
    MyPageView()
}
