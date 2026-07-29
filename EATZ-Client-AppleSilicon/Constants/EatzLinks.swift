//
//  EatzLink.swift
//  EATZ-Client-AppleSilicon
//
//  Created by 손원희 on 7/29/26.
//

import Foundation

enum EatzLinks {
    // EATZ 이용 약관 및 정책
    static let termsOfServiceString: String = "https://singers-yawn-d9w.craft.me/05yDHXOGXmtNJl"
    
    // EATZ 개인 정보 처리 방침 
    static let privacyPolicyString: String = "https://singers-yawn-d9w.craft.me/0vqpuHAw2wjMRf"
    
    static var termsOfServiceURL: URL? {
        guard let url = URL(string: termsOfServiceString) else {
            return nil
        }
        return url
    }
    
    static var privacyPolicyURL: URL? {
        guard let url = URL(string: privacyPolicyString) else {
            return nil
        }
        return url
    }
}
