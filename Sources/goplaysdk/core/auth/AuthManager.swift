//
//  AuthManager.swift
//  goplaysdk
//
//  Created by pate on 14/1/26.
//
import Combine
import Foundation
/*@MainActor*/
public class AuthManager: NSObject, @unchecked Sendable {
    
    public static let shared = AuthManager()
    

    // MARK: - Dependencies
    private var userStore: MemoryUserStore
    private var authStorage: KeychainAuthStorage


    private override init() {
        self.userStore  = MemoryUserStore()
        self.authStorage = KeychainAuthStorage()
        super.init()
    }

    // MARK: - Public API
    
    /// Check login state
    public func isLoggedIn() -> Bool {
        authStorage.loadCurrentSession() != nil
    }
    
    public func isActivePhone() -> Bool {
        let profile = userStore.load();
        return profile != nil && profile?.phone != nil && profile?.phone!.isNullOrEmpty == false
    }
    
    public func saveProfile(_ profile: UserProfile) {
        userStore.save(profile)
    }

    /// Call when login/signup succeeded
    public func handleLoginSuccess(_ session: GoPlaySession, _ notiEvent: Bool = true)  {
        // 1. Save tokens
         authStorage.saveCurrentSession(session)
        
         GoApiService.shared.getUserInfo(callback: { (user: UserProfile?) in
             if let user {
//                 print("handleLoginSuccess with phone \(user.phone ?? "nil")")
                     self.authStorage.saveUser(user)
                     self.userStore.save(user)
             }
        })

        // 2. Save user profile
//        userStore.save(response.user)
        if(notiEvent){
            AuthService.shared.postEventLogin(
                session: session,
                errorStr: nil
            )
        }
    }
    
    public func handleLoginError(_ apiResponse: GoPlayApiResponse<TokenData>)  {
        AuthService.shared.postEventResResult(
            resCode: apiResponse.code,
            error: apiResponse.message
        )
        
    }
    
    public func handleAccountLinking(_ sesion: GoPlaySession){
        AuthService.shared.postEventAccountLinking(
            session: sesion,
            error: nil
        )
    }
    
    public func saveSession(_ session: GoPlaySession){
        authStorage.saveCurrentSession(session)
    }

    /// Current logged-in user (cached)
    public func currentUser() -> UserProfile? {
        return userStore.load()
    }
    
    public func currentSesion()  -> GoPlaySession? {
        let session =  authStorage.loadCurrentSession()
            return session
    }

    /// Current access token for API calls
    public func currentAccessToken()  -> String? {
        let session =  authStorage.loadCurrentSession()
            return session?.accessToken
    }

    /// Logout / session invalid
    public func logout(_ error: String? = nil)  {
        if(error == nil){
            userStore.clear()
            KeychainHelper.clearDatalogOut()
            authStorage.clearAll()
        }
       
        
        AuthService.shared.postEventLogout(
            error: error
        )
        
    }


    
}
