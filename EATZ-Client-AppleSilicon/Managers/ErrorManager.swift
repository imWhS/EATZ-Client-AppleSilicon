//
//  ErrorManager.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 5/19/25.
//

import SwiftUI

class ErrorManager: ObservableObject {
    
    static let shared = ErrorManager()
    
    @Published var isErrorAlertPresented = false
    @Published var errorMessage: String?
    
    func showError(message: String) {
        errorMessage = message
        isErrorAlertPresented = true
    }
    
}
