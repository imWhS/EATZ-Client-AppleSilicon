//
//  CookableSearchButton.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/8/26.
//

import SwiftUI

struct CookableSearchButton: View {
    let isShowing: Bool
    let action: () -> Void
    
    var body: some View {
        if isShowing {
            VStack(spacing: 12) {
                Button(action: action) {
                    HStack(alignment: .center) {
                        Image("today-search")
                    }
                }
                .buttonStyle(TodaySearchButtonStyle())
            }
            .padding(20)
            .padding(.bottom, 12)
        } else {
            EmptyView()
        }
    }
}
