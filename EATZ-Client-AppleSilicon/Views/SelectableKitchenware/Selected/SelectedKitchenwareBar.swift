//
//  SelectedKitchenwareBar.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/22/25.
//

import SwiftUI

struct SelectedKitchenwareBar: View {
    var selection: [KitchenwareEssential] = []
    let onToggleSelection: (KitchenwareEssential) -> Void
    let placeholder: String

    private let barHeight: CGFloat = 88
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            if !selection.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(selection) { kitchenware in
                            SelectedKitchenwareItem(name: kitchenware.name, imageUrl: kitchenware.imageUrl, onDeselect: { onToggleSelection(kitchenware)
                            })
                        }
                    }
                    .padding(.horizontal, 20)
                    .animation(.easeInOut(duration: 0.2), value: selection)
                }
                .padding(.vertical, 20)
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            } else {
                emptyStateView
                    .padding(.vertical, 20)
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .background(Color.backgroundPrimary.ignoresSafeArea(edges: [.top, .bottom]))
    }
    
    private var emptyStateView: some View {
        Text(placeholder)
            .font(.system(size: 12))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.gray35)
            .frame(height: 48)
    }
}
