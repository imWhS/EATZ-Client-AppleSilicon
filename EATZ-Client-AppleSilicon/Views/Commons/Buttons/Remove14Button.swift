//
//  Remove14Button.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 8/2/26.
//

import SwiftUI

struct Remove14Button: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image("remove-14")
        }
        .buttonStyle(.plain)
        .foregroundColor(Color.accentColor)
    }
}
