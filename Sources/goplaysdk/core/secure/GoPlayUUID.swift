import Foundation
@MainActor
public class GoPlayUUID {
    
    static let shared = GoPlayUUID()
    
    private let uuidKey = "userUUIDKey"

    public var userUUID: String {
        if let storedUUID = loadUUID() {
            return storedUUID
        } else {
            let newUUID = UUID().uuidString
            saveUUID(newUUID)
            return newUUID
        }
    }
    
    // Load UUID from Keychain
    private func loadUUID() -> String? {
        if let data = KeychainHelper.load(key: uuidKey), let uuidString = String(data: data, encoding: .utf8) {
            return uuidString
        }
        return nil
    }
    
    // Save UUID to Keychain
    private func saveUUID(_ uuid: String) {
        if let data = uuid.data(using: .utf8) {
            KeychainHelper.save(key: uuidKey, data: data)
        }
    }
    
    // Optionally, remove UUID (e.g., on logout)
    func removeUUID() {
        KeychainHelper.remove(key: uuidKey)
    }
}
