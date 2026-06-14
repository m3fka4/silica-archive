import Foundation
import Security

struct KeychainService {
    func storePassword(_ password: String, account: String) throws {
        let data = Data(password.utf8)
        SecItemDelete(query(account: account) as CFDictionary)

        var item = query(account: account)
        item[kSecValueData as String] = data

        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandled(status) }
    }

    func password(account: String) throws -> String? {
        var item = query(account: account)
        item[kSecReturnData as String] = true
        item[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(item as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else { throw KeychainError.unhandled(status) }
        return String(data: data, encoding: .utf8)
    }

    private func query(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Silica",
            kSecAttrAccount as String: account
        ]
    }
}

enum KeychainError: Error {
    case unhandled(OSStatus)
}
