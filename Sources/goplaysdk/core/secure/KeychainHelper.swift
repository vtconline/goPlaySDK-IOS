//
//  keychainHelper.swift
//  goplaysdk
//
// 
//

import Foundation
import Security
class KeychainHelper {
    @MainActor static func loadCurrentSession() -> GoPlaySession?{
            if let loadedSession: GoPlaySession = KeychainHelper.load(key: GoConstants.goPlaySession, type: GoPlaySession.self) {
                return loadedSession
            }
        return nil
    }

    // Save any Codable object to Keychain
    static func save<T: Codable>(key: String, data: T) {
        do {
            // Encode the data object to Data
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            
            // Save to Keychain
            KeychainHelper.save(key: key, data: encodedData)
        } catch {
            print("Failed to encode \(T.self) data: \(error.localizedDescription)")
        }
    }
    
    // Overload for saving primitive types (e.g., String, Int, Bool)
    static func save(key: String, string: String) {
        if let data = string.data(using: .utf8) {
            KeychainHelper.save(key: key, data: data)
        }
    }
    
    static func save(key: String, int: Int) {
        let data = Data(from: int)
        KeychainHelper.save(key: key, data: data)
    }
    
    static func save(key: String, bool: Bool) {
        let data = Data(from: bool)
        KeychainHelper.save(key: key, data: data)
    }
    
    // Load any Codable object from Keychain
//    if let loadedSession: GoPlaySession = KeychainHelper.load(key: GoConstants.goPlaySession, type: GoPlaySession.self) {
//        print("Loaded GoPlaySession: \(loadedSession)")
//    }
    static func load<T: Codable>(key: String, type: T.Type) -> T? {
        if let data = KeychainHelper.load(key: key) {
            do {
                // Decode the data back to the expected type
                let decoder = JSONDecoder()
                let decodedObject = try decoder.decode(T.self, from: data)
                return decodedObject
            } catch {
                print("KeyChianHelper:Failed to decode \(T.self) key: \(key) , data: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
//    Load any type from Keychain, works for String, Int, Bool
//    KeychainHelper.save(key: "username", string: "johnDoe")
//    KeychainHelper.save(key: "userAge", int: 30)
//    KeychainHelper.save(key: "isLoggedIn", bool: true)
//    if let userName: String = KeychainHelper.load(key: "username", type: String.self) {
//        print("Loaded userName: \(userName)")
//    }
    static func load<T>(key: String, type: T.Type) -> T? {
            if let data = KeychainHelper.load(key: key) {
                if T.self == String.self {
                    return String(data: data, encoding: .utf8) as? T
                } else if T.self == Int.self {
                    return data.toInt() as? T
                } else if T.self == Bool.self {
                    return data.toBool() as? T
                } else {
                    return nil
                }
            }
            return nil
        }


    
    static func clearSavedData() {
        // Clear username from UserDefaults
        UserDefaults.standard.removeObject(forKey: "savedUsername")
        
        // Clear password from Keychain
        if let _ = KeychainHelper.load(key: "savedPassword", type: String.self) {
            KeychainHelper.remove(key: "savedPassword")
        }
        
        // Clear GoPlaySession from Keychain
        KeychainHelper.remove(key: GoConstants.goPlaySession)
    }
    
    static func clearDatalogOut() {
        // Clear username from UserDefaults
//        UserDefaults.standard.removeObject(forKey: "savedUsername")
//        
//        // Clear password from Keychain
//        if let _ = KeychainHelper.load(key: "savedPassword", type: String.self) {
//            KeychainHelper.remove(key: "savedPassword")
//        }
        
        // Clear GoPlaySession from Keychain
        KeychainHelper.remove(key: GoConstants.goPlaySession)
    }

    // MARK: - Private Methods
    
    // Save Data to Keychain
    static func save(key: String, data: Data) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as CFDictionary

        SecItemDelete(query)
        SecItemAdd(query, nil)
    }

    // Load Data from Keychain
    static func load(key: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)

        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        return nil
    }
    
    // Remove Data from Keychain
    static func remove(key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        
        SecItemDelete(query) // Remove item from Keychain
    }
}

extension Data {
    // Helper to convert Int to Data
    init(from int: Int) {
        var value = int
        self = Swift.withUnsafeBytes(of: &value) { Data($0) }
    }
    
    // Helper to convert Bool to Data
    init(from bool: Bool) {
        var value = bool
        self = Swift.withUnsafeBytes(of: &value) { Data($0) }
    }
    
    // Helper to convert Data back to Int
    func toInt() -> Int? {
        return self.withUnsafeBytes { $0.load(as: Int.self) }
    }
    
    // Helper to convert Data back to Bool
    func toBool() -> Bool? {
        return self.withUnsafeBytes { $0.load(as: Bool.self) }
    }
}
