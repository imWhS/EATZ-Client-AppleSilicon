//
//  KeychainService.swift
//  Eatz-AppleSilicon
//
//  Created by 손원희 on 5/9/25.
//

import Foundation

final class KeychainService {
    
    private init() {}
    
    /// 키에 대응하는 데이터를 keychain에 저장합니다.
    @discardableResult
    static func save(_ value: String, key: String) -> Bool {
       delete(key: key)

       guard let data = value.data(using: .utf8) else { return false }

       let query: [String: Any] = [
           kSecClass as String:           kSecClassGenericPassword,
           kSecAttrAccount as String:     key,
           kSecValueData as String:       data,
           kSecAttrAccessible as String:  kSecAttrAccessibleAfterFirstUnlock
       ]

       let status = SecItemAdd(query as CFDictionary, nil)
        if !(status == errSecSuccess) {
            print("[KeychainService] \(key)로 \(value)를 저장하지 못했어요.")
        }
       return status == errSecSuccess
    }
    
    /// 키에 대응하는 데이터를 keychain에서 불러옵니다.
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String:           kSecClassGenericPassword,
            kSecAttrAccount as String:     key,
            kSecReturnData as String:      kCFBooleanTrue as Any,
            kSecMatchLimit as String:      kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let str = String(data: data, encoding: .utf8)
        else {
            print("AUTHDBG [KeychainService] '\(key)'에 해당하는 데이터를 불러오지 못했어요.")
            return nil
        }
        return str
    }
    
    @discardableResult
    static func delete(key: String) -> Bool {
        print("[KeychainService] '\(key)'에 해당하는 데이터를 삭제할게요.")
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
}
