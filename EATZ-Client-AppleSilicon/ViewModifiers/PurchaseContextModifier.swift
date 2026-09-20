//
//  PurchaseContextModifier.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 9/18/26.
//

import SwiftUI

struct PurchaseItem: Identifiable {
    var type: RequirementType
    var id: Int64
    var name: String
}

struct PurchaseContextModifier: ViewModifier {
    @Binding var isPresented: Bool
    var item: PurchaseItem?
    
    init(_ isPresented: Binding<Bool>, _ item: PurchaseItem?) {
        self._isPresented = isPresented
        self.item = item
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: { }) {
                AffiliateLinkNoticeView(item)
                    .presentationDetents([.height(450)])
                    .presentationDragIndicator(.visible)
            }
    }
}

extension View {
    func getPurchaseContext(_ isPresented: Binding<Bool>, item: PurchaseItem?) -> some View {
        return self.modifier(PurchaseContextModifier(isPresented, item))
    }
}
