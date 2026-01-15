//
//  KeychainAuthStorage.swift
//  goplaysdk
//
//  Created by pate on 14/1/26.
//

import Foundation

//@MainActor
public class KeychainAuthStorage {
    private let userKey = "goplay.user.profile"
    private let tokenKey = "goplay.auth.token"

    public init() {}
    
    public func clearAll()  {
         clearUser()
         clearCurrentSession()
    }
    
    public func saveCurrentSession(_ session: GoPlaySession)  {
        KeychainHelper.save(key: GoConstants.goPlaySession, data: session)
        
    }
    
    public func loadCurrentSession() -> GoPlaySession? {
        if let loadedSession: GoPlaySession = KeychainHelper.load(
            key: GoConstants.goPlaySession, type: GoPlaySession.self)
        {
            return loadedSession
        }
        return nil
    }
    
    public func clearCurrentSession() {
        KeychainHelper.remove(key: GoConstants.goPlaySession)
    }
    
    

    // MARK: - User

    public func saveUser(_ user: UserProfile)  {
        do {
            let data = try JSONEncoder().encode(user)
            KeychainHelper.save(key: userKey, data: data)
        } catch {
            assertionFailure("❌ Failed to encode UserProfile: \(error)")
        }
    }

    public func getUser() async -> UserProfile? {
        guard let data = KeychainHelper.load(key: userKey) else {
            return nil
        }

        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    public func clearUser() {
        KeychainHelper.remove(key: userKey)
    }

    // MARK: - Token

    public func saveToken(_ token: String) async {
        let data = Data(token.utf8)
        KeychainHelper.save(key: tokenKey, data: data)
    }

    public func getToken() async -> String? {
        guard let data = KeychainHelper.load(key: tokenKey) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    public func clearToken() async {
        KeychainHelper.remove(key: tokenKey)
    }
}
