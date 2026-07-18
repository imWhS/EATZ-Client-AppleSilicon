//
//  MyAccountSummaryRowSection.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/2/26.
//

import SwiftUI

struct MyAccountSummaryRowSection: View {
    let label: String
    let count: Int?
    let onDisclosureTapped: () -> Void
    
    var body: some View {
        if let count = count {
            VStack(spacing: 10) {
                BasicMenuRow(label, .navigation, "\(count)개", onTapped: onDisclosureTapped)
                HorizontalDivider()
            }
            .padding(.top, 10)
        }
    }
}
