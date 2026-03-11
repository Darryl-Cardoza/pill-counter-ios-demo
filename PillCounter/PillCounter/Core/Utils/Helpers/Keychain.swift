//
//  Keychain.swift
//  PillCounter
//
//  Created by HC on 05/11/25.
//

import Foundation
import Security

final class Keychain {

    static func savePassword(
        _ password: String, for key: String, service: String = "PillCounter"
    ) {
        let data = password.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecValueData as String: data,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    static func getPassword(for key: String, service: String = "PillCounter")
        -> String?
    {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
            let data = result as? Data,
            let password = String(data: data, encoding: .utf8)
        {
            return password
        }
        return nil
    }
}
