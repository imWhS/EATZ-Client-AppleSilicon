//
//  AppConfig.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/5/26.
//

import Foundation

struct AppConfig {
    
    #if DEBUG
    static let serverDomain = "http://localhost:8080"
    #else
    static let serverDomain = "https://api.eatz.io"
    #endif
    
    static var apiBaseUrl: String {
        return "\(serverDomain)/api"
    }
    
    static var servingImageBaseUrl: String {
        return serverDomain
    }
    
    static let baseUrl = "http://localhost:8080"
}
    
