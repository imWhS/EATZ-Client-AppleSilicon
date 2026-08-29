//
//  MyAccountPantryItemContainer.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 10/26/25.
//

import SwiftUI

struct MyAccountPantryItemContainer<Content: View>: View {
    let title: String
    let count: Int
    let onDetailTapped: () -> Void
    @ViewBuilder let header: Content
    
    private var countLabel: String? {
        if 0 < count { return "\(count)개 보관 중" }
        else { return nil }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            detailSection
        }
        .background(Color.white)
        .cornerRadius(14)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private var actionButton: some View {
        BasicMenuRow(title, false, .navigation, countLabel, onTapped: onDetailTapped)
    }
    
    private var detailSection: some View {
        VStack(spacing: 0) {
            HorizontalDivider(padding: 20)
            actionButton
        }
    }
}
