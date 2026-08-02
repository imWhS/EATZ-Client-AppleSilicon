//
//  SupportEmailUtli.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/29/26.
//

import SwiftUI

enum SupportEmailUtli {
    static func createEmailURL() -> URL? {
        let subject = "[EATZ] (여기를 지우고 제목을 작성해 주세요!)"
        
        var clientVersion: String {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "알 수 없음"
        }
        
        var iosVersion: String {
            UIDevice.current.systemVersion
        }
        
        var clientBuildNumber: String {
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
       }
        
        let body =
                """
                (여기를 지우고 내용을 작성해 주세요!)
                
                —
                아래 내용은 지우지 말고 그대로 남겨주세요!
                * EATZ iOS 버전: \(clientVersion) (\(clientBuildNumber))
                * iOS 버전: \(iosVersion)
                """
        
        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
                
        return URL(string: "mailto:\(EatzLinks.developerEmailString)?subject=\(encodedSubject)&body=\(encodedBody)")
    }
}
