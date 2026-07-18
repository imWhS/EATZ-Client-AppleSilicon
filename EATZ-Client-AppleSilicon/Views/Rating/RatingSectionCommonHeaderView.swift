//
//  RatingSectionCommonHeaderView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 11/19/25.
//

import SwiftUI

struct RatingSectionCommonHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
