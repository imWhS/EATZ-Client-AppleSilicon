//
//  RecipeWebPageView.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/8/26.
//

import SwiftUI
import SafariServices

struct RecipeWebPageView: UIViewControllerRepresentable {
    let recipeUrl: URL
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = SFSafariViewController(url: recipeUrl)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //
    }
}

