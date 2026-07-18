//
//  ReportContextModifier.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/22/26.
//

import SwiftUI

struct ReportContextModifier: ViewModifier {
    @Binding var resource: ReportResource?
    
    init(_ resource: Binding<ReportResource?>) {
        self._resource = resource
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $resource, onDismiss: { }) { resource in
                ReportView(resource)
            }
    }
    
    
}

extension View {
    func getReportContext(resource: Binding<ReportResource?>) -> some View {
        self.modifier(ReportContextModifier(resource))
    }
}
