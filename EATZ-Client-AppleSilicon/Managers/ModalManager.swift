//
//  ModalManager.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 6/7/25.
//

import SwiftUI

final class ModalManager: ObservableObject {
    
    static let shared = ModalManager()
    
    @Published var sheet: ModalRoute?
    
    private init() {}
    
}
