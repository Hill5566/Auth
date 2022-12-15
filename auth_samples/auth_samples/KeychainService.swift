//
//  KeychainService.swift
//  auth_samples
//
//  Created by Lin Hill on 2022/12/10.
//

import Foundation

class KeychainService {
    func save(_ password: String, for account: String) {
        let password = password.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecValueData as String: password]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { return print("save error") }
    }
    
    func retrivePassword(for account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: kCFBooleanTrue]
        
        
        var retrivedData: AnyObject? = nil
        let _ = SecItemCopyMatching(query as CFDictionary, &retrivedData)
        
        
        guard let data = retrivedData as? Data else {return nil}
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func testPaswordRetrive() {
        let password = "123456"
        let account = "User"
        let keyChainService = KeychainService()
        keyChainService.save(password, for: account)
        print(keyChainService.retrivePassword(for: account))
//        XCTAssertEqual(keyChainService.retrivePassword(for: account), password)
    }
}
