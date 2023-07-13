import Foundation

public class Keychain {
    
    public static func read(_ key: String, groupName: String? = nil) -> Data? {
        var keychainQuery: [AnyHashable: Any] = [
            kSecClass as AnyHashable: kSecClassGenericPassword,
            kSecAttrAccount as AnyHashable: key,
            kSecReturnData as AnyHashable: kCFBooleanTrue!,
            kSecMatchLimit as AnyHashable: kSecMatchLimitOne
        ]
        
        if let groupName = groupName {
            keychainQuery[kSecAttrAccessGroup as AnyHashable] = groupName
        }
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0))
        }
                
        guard status == errSecSuccess else { return nil }
        guard let data = result as? Data else { return nil }
        
        return data
    }
    
    public static func delete(_ key: String, groupName: String? = nil) {
        var keychainQuery: [AnyHashable: Any] = [
            kSecClass as AnyHashable: kSecClassGenericPassword,
            kSecAttrAccount as AnyHashable: key
        ]
        
        if let groupName = groupName {
            keychainQuery[kSecAttrAccessGroup as AnyHashable] = groupName
        }
        
        SecItemDelete(keychainQuery as CFDictionary)
    }
    
    public static func save(_ key: String,
                            value: Data,
                            groupName: String? = nil,
                            accessibleAttribute: CFString = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly) {
        self.delete(key, groupName: groupName)
                
        var keychainQuery: [AnyHashable: Any] = [
            kSecClass as AnyHashable: kSecClassGenericPassword,
            kSecAttrAccessible as AnyHashable: accessibleAttribute,
            kSecAttrAccount as AnyHashable: key,
            kSecValueData as AnyHashable: value
        ]
        
        if let groupName = groupName {
            keychainQuery[kSecAttrAccessGroup as AnyHashable] = groupName
        }
        
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
}
