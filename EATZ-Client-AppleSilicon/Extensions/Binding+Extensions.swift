//
//  Binding+Extensions.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/28/26.
//

import SwiftUI

extension Binding where Value == Bool {
    init<T>(isPresenting data: Binding<T?>) {
        self.init(
            get: {
                data.wrappedValue != nil
            },
            set: { isPresented in
                if !isPresented {
                    DispatchQueue.main.async {
                        data.wrappedValue = nil
                    }
                }
            }
        )
    }
}
