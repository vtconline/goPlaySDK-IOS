//
//  PayLoadUserInfo.swift
//  goplaysdk
//
//  Created by pate on 20/1/26.
//


import Foundation
import SwiftJWT

struct PayLoadUserInfo: Claims {

    // MARK: - JWT Standard / Custom Claims

    /// issuer, ví dụ: "https://goplay.vn"
    let iss: String?

    /// clientId (login client)
    let sub: String? 

    /// token type: access_token / refresh_token
    let aud: String?

    /// expired time (unix time, seconds)
    var exp: Int

    /// serviceId
    let sid: Int?

    /// database access token / service access token
    let atk: String?

    /// account type
    /// 0: fast play, 1: goID, 2: Facebook, 3: Google, 4: Apple
    let aty: UInt8?

    /// userId / accountId
    let uid: Int64

    /// username (nullable)
    let name: String?

    /// deviceId
    let dvId: String?

    /// os
    let os: String?

    /// client IP
    let ip: String?

    /// status of account
    /// 0: Block, 1: Email, 2: Mobile, 5: Mobile & Email
    let sta: UInt8?

    /// scopes string, ví dụ: "sso auth update"
    let scopes: String?

    /// sso flag
    let sso: UInt8?
    
    init(
        iss: String = "https://goplay.vn",
        sub: String = "empty_client_id",
        aud: String = GoTokenType.access_token,
        exp: Int = 0,
        sid: Int = 0,
        atk: String = "",
        aty: UInt8 = 1,
        uid: Int64 = 0,
        name: String = "",
        dvId: String = "",
        os: String = "",
        ip: String = "",
        sta: UInt8? = nil,
        scopes: String = "",
        sso: UInt8? = nil
    ) {
        self.iss = iss
        self.sub = sub
        self.aud = aud
        self.exp = exp
        self.sid = sid
        self.atk = atk
        self.aty = aty
        self.uid = uid
        self.name = name
        self.dvId = dvId
        self.os = os
        self.ip = ip
        self.sta = sta
        self.scopes = scopes
        self.sso = sso
    }

    // MARK: - Computed Properties (Logic giống C#)

    /// Check token expired
    func isExpired(preSec: Int = 0) -> Bool {
        let now = Int(Date().timeIntervalSince1970)
        return (now - preSec) > exp
    }

    /// Is authenticated
    var isAuthenticated: Bool {
        guard !isExpired() else { return false }
        return uid > 0
    }

    /// Is blocked
    var isBlock: Bool {
        return sta == 0
    }

    /// Is active (Email / Mobile / Mobile & Email)
    var isActive: Bool {
        return sta == 1 || sta == 2  || sta == 5
    }

    /// Active mobile
    var isActiveMobile: Bool {
        return sta == 2  || sta == 5
    }

    /// Active email
    var isActiveMail: Bool {
        return sta == 1 || sta == 5
    }
}
