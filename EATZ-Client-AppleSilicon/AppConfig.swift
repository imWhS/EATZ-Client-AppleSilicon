//
//  AppConfig.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/5/26.
//

import Foundation

struct AppConfig {
    // Info.plist의 BASE_URL key에 등록된 값을 가져옵니다.
    static var serverDomain: String {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("Info.plist에 BASE_URL key가 설정되지 않았어요.")
        }
        
        #if DEBUG
        print("현재 서버 도메인: \(urlString)")
        #endif
        
//        return urlString
        return "http://localhost:8080"
    }
    
    static var apiBaseUrl: String {
        return "\(serverDomain)/api"
    }
    
    static var servingImageBaseUrl: String {
        return serverDomain
    }
}
    
