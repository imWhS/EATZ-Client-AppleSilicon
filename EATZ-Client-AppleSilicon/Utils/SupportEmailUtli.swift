//
//  SupportEmailUtli.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/29/26.
//

import SwiftUI

enum SupportEmailUtli {
    static func createEmailURL(currentUser: CurrentUser?) -> URL? {
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
        
        var body: String {
            guard let currentUser = currentUser else {
                return """
                (여기를 지우고 내용을 작성해 주세요!)
                
                —
                아래 내용은 지우지 말고 그대로 남겨주세요
                * Guest
                * EATZ iOS 버전: \(clientVersion) (\(clientBuildNumber))
                * iOS 버전: \(iosVersion)
                """
            }
            
            return  """
                (여기를 지우고 내용을 작성해 주세요!)
                
                —
                아래 내용은 지우지 말고 그대로 남겨주세요!
                * Public ID: \(currentUser.publicId)
                * EATZ iOS 버전: \(clientVersion) (\(clientBuildNumber))
                * iOS 버전: \(iosVersion)
                """
        }
        
        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
                
        return URL(string: "mailto:\(EatzLinks.developerEmailString)?subject=\(encodedSubject)&body=\(encodedBody)")
    }
}
