//
//  MyAccountPantryHeader.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

struct MyAccountPantryHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
