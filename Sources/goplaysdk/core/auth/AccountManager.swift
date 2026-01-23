//
//  AccountManager.swift
//  goplaysdk
//
//  Created by pate on 22/1/26.
//

import Combine
import Foundation

//try AccountManager.saveAndSetCurrent(
//    Account(
//        userId: "10001",
//        username: "kaka167",
//        credential: "access_token_xyz"
//    )
//)
//
//let current = AccountManager.currentAccount()
//let all = AccountManager.allAccounts()
//
//try AccountManager.logoutCurrent()
public final class AccountManager {

    // MARK: - Constants
    private static let service = "com.vtc.sdk.accounts"
    private static let accountKey = "account_list"
    private static let currentUserKey = "current_user_id"
    private static let maxAccounts = 10

    // MARK: - Public API

    /// Luôn trả array an toàn, KHÔNG crash
    public static func allAccounts() -> [Account] {
        return (try? loadAccounts()) ?? []
    }

    /// Current account, có thể nil
    public static func currentAccount() -> Account? {
         let id = UserDefaults.standard.integer(forKey: currentUserKey) 
        return allAccounts().first { $0.userId == id }
    }

    /// Save + set current (Result để app host xử lý UX)
    @discardableResult
    public static func saveAndSetCurrent(
        _ account: Account
    ) -> Result<Void, AccountManagerError> {
        do {
            try saveInternal(account)
            setCurrent(account.userId)
            return .success(())
        } catch let error as AccountManagerError {
            return .failure(error)
        } catch {
            return .failure(.encodeFailed)
        }
    }

    /// Remove 1 account
    public static func removeAccount(userId: Int) -> Result<Void, AccountManagerError> {
        do {
            var accounts = try loadAccounts()
            accounts.removeAll { $0.userId == userId }

            if accounts.isEmpty {
                clearKeychain()
                UserDefaults.standard.removeObject(forKey: currentUserKey)
            } else {
                try persist(accounts)
                if currentAccount()?.userId == userId {
                    setCurrent(accounts.first!.userId)
                }
            }
            return .success(())
        } catch let error as AccountManagerError {
            return .failure(error)
        } catch {
            return .failure(.decodeFailed)
        }
    }
    
    public static func updateAccount(
        userId: Int,
        credential: String? = nil,
        lastLogin: Date? = nil,
        setAsCurrent: Bool = true
    ) -> Result<Void, AccountManagerError> {

        do {
            var accounts = try loadAccounts()

            guard let index = accounts.firstIndex(where: { $0.userId == userId }) else {
                return .failure(.decodeFailed) // hoặc custom .notFound nếu anh muốn
            }

            let old = accounts[index]

            let updated = Account(
                userId: old.userId,
                username: old.username,
                credential: credential ?? old.credential,
                lastLogin: lastLogin ?? old.lastLogin
            )

            accounts[index] = updated
            accounts.sort { $0.lastLogin > $1.lastLogin }

            try persist(accounts)

            if setAsCurrent {
                setCurrent(userId)
            }

            return .success(())

        } catch let error as AccountManagerError {
            return .failure(error)
        } catch {
            return .failure(.encodeFailed)
        }
    }


    /// Logout current user (fail-safe)
    public static func logoutCurrent() {
        guard let current = currentAccount() else { return }
        _ = removeAccount(userId: current.userId)
    }

    // MARK: - Internal Logic

    private static func saveInternal(_ account: Account) throws {
        var accounts = try loadAccounts()

        if let index = accounts.firstIndex(where: { $0.userId == account.userId }) {
            accounts[index] = account
        } else {
            guard accounts.count < maxAccounts else {
                throw AccountManagerError.accountLimitReached(max: maxAccounts)
            }
            accounts.append(account)
        }

        accounts.sort { $0.lastLogin > $1.lastLogin }
        try persist(accounts)
    }

    private static func setCurrent(_ userId: Int) {
        UserDefaults.standard.set(userId, forKey: currentUserKey)
    }

    // MARK: - Keychain

    private static func loadAccounts() throws -> [Account] {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: accountKey,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return []
        }

        guard status == errSecSuccess else {
            throw AccountManagerError.keychain(status)
        }

        guard
            let data = result as? Data,
            let accounts = try? JSONDecoder().decode([Account].self, from: data)
        else {
            throw AccountManagerError.decodeFailed
        }

        return accounts
    }

    private static func persist(_ accounts: [Account]) throws {
        guard let data = try? JSONEncoder().encode(accounts) else {
            throw AccountManagerError.encodeFailed
        }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: accountKey
        ]

        let attributes: [CFString: Any] = [
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            var newItem = query
            newItem.merge(attributes) { $1 }
            let addStatus = SecItemAdd(newItem as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw AccountManagerError.keychain(addStatus)
            }
        } else if status != errSecSuccess {
            throw AccountManagerError.keychain(status)
        }
    }

    private static func clearKeychain() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: accountKey
        ]
        SecItemDelete(query as CFDictionary)
    }
}


public enum AccountManagerError: Error {
    case keychain(OSStatus)
    case encodeFailed
    case decodeFailed
    case accountLimitReached(max: Int)
}

public struct Account: Codable, Equatable {
    public let userId: Int
    public let username: String
    public let credential: String   // password / token
    public let lastLogin: Date

    public init(
        userId: Int,
        username: String,
        credential: String,
        lastLogin: Date = Date()
    ) {
        self.userId = userId
        self.username = username
        self.credential = credential
        self.lastLogin = lastLogin
    }
}

