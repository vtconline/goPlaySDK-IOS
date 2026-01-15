
import Foundation


@objc public final class GoPlaySession: NSObject,Codable, @unchecked Sendable {
    @objc public var  accessToken: String? = nil
    @objc public var  refreshToken: String? = nil
    @objc public var  expiresIn: Int = 0
    @objc public var  userId: Int64 = 0
    @objc public var userName: String? = nil
    @objc public var  accountType: Int = 0

    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case expiresIn = "expires_in"
        case userId
        case userName
        case accountType
    }
    
    static func deserialize(data: TokenData) -> GoPlaySession? {
        var session = GoPlaySession()
        do {
            //print("JwtParser: \(data)")
            
            session.accessToken = data.accessToken
            session.refreshToken = data.refreshToken
            session.expiresIn = data.expiresIn
            
            // Remove signature part from JWT
            guard let withoutSign = Utils.removeSign(jwt: session.accessToken) else {
                print("Failed to remove JWT signature")
                return nil
            }
            
            // Decode JWT payload
            if let claims = Utils.parseClaimsJwt(jwt: withoutSign) {
//                print("JwtParser claims: \(claims)")
                
                if let uid = claims["uid"] as? NSNumber {
                    session.userId = uid.int64Value
                }
                if let name = claims["name"] as? String {
                    session.userName = name
                }
                if let aty = claims["aty"] as? NSNumber {
                    session.accountType = aty.intValue
                }
            }
            
//            print("JwtParser session: \(session)")
            return session
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
