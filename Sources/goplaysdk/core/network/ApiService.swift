import Foundation
import SwiftJWT

@MainActor
public class ApiService : @unchecked Sendable {
    private var isSandBox = false
    private var baseURL = GoApi.apiSandbox

    public var clientId: String = "2356aa1f65af420c"
    public var clientSecret: String = "SwlDJHfkE8F8ldQr9wzwDF6jTMRG6+/5"
    //product 1FsNyzLRvKSAibDOjPLGBxVlLsvvHwXJc7TAraPktaQ=
    //dev "GQDstcKsx0NHjPOuXOYg5MbeJ1XT0uFiwDVvVBrk"
    public var jwtBearerEcryptKey: String = "GQDstcKsx0NHjPOuXOYg5MbeJ1XT0uFiwDVvVBrk"
    
    public static let shared = ApiService()
    private init() {}

    private var isInitialized = false
    private var signer: JWTSigner?
    private var signerEncryptKey: JWTSigner?

    func initJwtIfNeeded() async {
        guard !isInitialized else { return }
        isInitialized = true
//        print("Initializing JWT signer...")
        
        let keyData = Data(clientSecret.utf8)
        signer = JWTSigner.hs256(key: keyData)
        
        //project gopalyservices.authen class JwtBearerSettings.cs have jwtBearerEcryptKey
        //must sychronize
        let keyDataEncrypt = Data("\(clientSecret)\(jwtBearerEcryptKey)".utf8)
        signerEncryptKey = JWTSigner.hs256(key: keyDataEncrypt)
//        signerEncryptKey = JWTSigner.hs256(key: keyData)
        
//        print("JWT signer ready.")
    }

    private var bearerToken: String? {
        return nil
    }
    
    public func initWithKey(_ isSandBox: Bool,_ clientId: String,_ clientSecret: String) {
        self.isSandBox = isSandBox
        if self.isSandBox {
            self.baseURL = GoApi.apiSandbox
//            self.clientId = "2356aa1f65af420c"
//            self.clientSecret  = "SwlDJHfkE8F8ldQr9wzwDF6jTMRG6+/5"
            self.jwtBearerEcryptKey = "GQDstcKsx0NHjPOuXOYg5MbeJ1XT0uFiwDVvVBrk"
        }else {
            self.baseURL = GoApi.apiProduct
//            self.clientId = "29658d7cd198458a"
//            self.clientSecret  = "63/k6+G2LQVrFUOUOMvPzhz2scuwlBSrPMq+8UpMBRfTuWVGL+Aa2Q5i7rLzIy20"
            self.jwtBearerEcryptKey = "1FsNyzLRvKSAibDOjPLGBxVlLsvvHwXJc7TAraPktaQ="
        }
        self.clientId = clientId
        self.clientSecret  = clientSecret
    }

    func setBaseURL(_ newBaseURL: String) {
        self.baseURL = newBaseURL
    }

    func get(path: String,  bodyJwtSign:[String: Any]? = nil,payloadType: Int = GoPayloadType.clientInfo, completion: @escaping (Result<Data, Error>) -> Void) async {
        await request(method: "GET", path: path, bodyJwtSign: bodyJwtSign, payloadType: payloadType, completion: completion)
    }

    func post(path: String, body: [String: Any]? = nil, bodyJwtSign:[String: Any]? = nil, payloadType: Int = GoPayloadType.clientInfo, completion: @escaping (Result<Data, Error>) -> Void) async {
        await request(method: "POST", path: path, body: body, bodyJwtSign: bodyJwtSign, payloadType: payloadType, completion: completion)
    }
    
    private func request(
        method: String,
        path: String,
        body: [String: Any]? = nil,
        bodyJwtSign:[String: Any]? = nil,
        payloadType: Int = GoPayloadType.clientInfo,
        completion: @escaping (Result<Data, Error>) -> Void
    ) async {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            print("Invalid URL")
            return
        }
//        print("url URL \(url)")

        await initJwtIfNeeded()
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let partnerParams = Utils.getPartnerParams()
        var bodyParams: [String: Any] = [:]
        var bodyMerge: [String: Any]? = body

        if method == "POST" {
           
                
        
                bodyParams["cid"] = clientId
                bodyParams["clientId"] = clientId
                bodyParams = bodyParams.merging(body ?? [:]) { current, _ in current }
                bodyParams = bodyParams.merging(partnerParams ?? [:]) { current, _ in current }
                if var signBody = bodyJwtSign {
                    signBody = signBody.merging(partnerParams) { current, _ in current }
                    bodyParams["jwt"] = await generatePayloadWithType(data: signBody, payloadType: payloadType) ?? ""
                }
                
                if bodyParams.keys.contains("jwt") {
//#if DEBUG
//                    print("✅ bodyParams chứa key jwt ==> no add \(bodyParams)")
//#endif
                } else {
                    bodyParams["jwt"] = KeychainHelper.loadCurrentSession()?.accessToken ?? ""
                }

            

            if let token = bearerToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
                request.httpBody = jsonData
            } catch {
                completion(.failure(error))
                return
            }
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                completion(.success(data))
            } else {
                let error = NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
                completion(.failure(error))
            }
        }

        task.resume()
    }

    private func request22(
        method: String,
        path: String,
        body: [String: Any]? = nil,
        sign: Bool = false,
        jwtSign:[String: Any]? = nil,
        payloadType: Int = GoPayloadType.clientInfo,
        completion: @escaping (Result<Data, Error>) -> Void
    ) async {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            print("Invalid URL")
            return
        }
        print("url URL \(url)")

        await initJwtIfNeeded()
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let partnerParams = Utils.getPartnerParams()
        var bodyParams: [String: Any] = [:]
        var bodyMerge: [String: Any]? = body

        if method == "POST", var requestBody = bodyMerge {
            if sign {
                if var mergedBody = bodyMerge {
//                    let partnerParams = Utils.getPartnerParams()
                    mergedBody = mergedBody.merging(partnerParams) { current, _ in current }
                    bodyMerge = mergedBody
                }
                
                bodyMerge?["cid"] = clientId
                bodyMerge?["clientId"] = clientId
                bodyParams = bodyParams.merging(body ?? [:]) { current, _ in current }
//                print("requestBody before jwt \(bodyMerge)")
                bodyParams["jwt"] = await generatePayloadWithType(data: bodyMerge, payloadType: payloadType) ?? ""
            } else {
                
        
                bodyParams["cid"] = clientId
                bodyParams["clientId"] = clientId
                bodyParams = bodyParams.merging(partnerParams ?? [:]) { current, _ in current }
                bodyParams = bodyParams.merging(bodyMerge ?? [:]) { current, _ in current }
                if bodyParams.keys.contains("jwt") {
#if DEBUG
                    print("✅ bodyParams chứa key jwt ==> no add \(bodyParams)")
#endif
                } else {
                    bodyParams["jwt"] = KeychainHelper.loadCurrentSession()?.accessToken ?? ""
                }
//                print("requestBody bodyMerge no sign  \(bodyMerge)")
//                print("requestBody bodyParams no sign  \(bodyParams)")
            }

            if let token = bearerToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
                request.httpBody = jsonData
            } catch {
                completion(.failure(error))
                return
            }
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                completion(.success(data))
            } else {
                let error = NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
                completion(.failure(error))
            }
        }

        task.resume()
    }

    // MARK: - SwiftJWT Claims
    struct MyClaims: Claims {
        var jti: String
        var iss: String
        var nbf: Int
        var exp: Int
        var sid: Int
        var jdt: String
    }
    
    func generateSignature<C: Claims>(
        claims: C, useEncrypt: Bool = false
    ) async -> String? {

        await initJwtIfNeeded()

        guard let signer = (useEncrypt ? signerEncryptKey : signer) else {
            print("Signer not initialized")
            return nil
        }

        do {
            var jwt = JWT(claims: claims)
            let signedToken = try jwt.sign(using: signer)
//            print("jwt \(signedToken)")
            return signedToken
        } catch {
            print("JWT signing error: \(error)")
            return nil
        }
    }

    func generatePayloadWithType(data: Any, payloadType: Int = GoPayloadType.clientInfo) async -> String? {
        await initJwtIfNeeded()

        guard let signer = signer else {
            print("Signer not initialized")
            return nil
        }

        let jti = Int64(Date().timeIntervalSince1970 * 1000)
        let nbf = jti / 1000
        let exp = nbf + 60

        do {
            let jsonData: String
            if let json = try? JSONSerialization.data(withJSONObject: data),
               let jsonStr = String(data: json, encoding: .utf8) {
                jsonData = jsonStr
            } else {
                jsonData = String(describing: data)
            }
            
            var isEncrypt = false
            let claims: Claims;
            switch payloadType {
            case GoPayloadType.clientInfo:
                claims = MyClaims(
                    jti: String(jti),
                    iss: clientId,
                    nbf: Int(nbf),
                    exp: Int(exp),
                    sid: 0,
                    jdt: jsonData
                )
                break
            case GoPayloadType.userInfo:
                isEncrypt = true
                let goPlaySession =  AuthManager.shared.currentSesion()
                claims = PayLoadUserInfo(
                    iss: isSandBox ? "https://dev.goplay.vn" : "https://goplay.vn",
                    sub: clientId,
    //                aud: "access_token",
                    exp: Int(exp),
                    sid: 0,
                    
                    aty: UInt8(goPlaySession?.accountType ?? 1),//0: fast play, 1: goID, 2: Facebook, 3: Google, 4: Apple
                    uid: goPlaySession?.userId ?? 0,
                    name: goPlaySession?.userName ?? "",
                    dvId : GoPlayUUID.shared.userUUID,
                    os : "ios"
                )
                break
            default:
                claims = MyClaims(
                    jti: String(jti),
                    iss: clientId,
                    nbf: Int(nbf),
                    exp: Int(exp),
                    sid: 0,
                    jdt: jsonData
                )
                break
            }

            

            
            let signedToken = await generateSignature(claims: claims, useEncrypt: isEncrypt)
            return signedToken
        } catch {
            
            return nil
        }
    }
    
    func generatePayloadUserInfo(data: Any) async -> String? {
        await initJwtIfNeeded()

        guard let signer = signer else {
            print("Signer not initialized")
            return nil
        }

        let jti = Int64(Date().timeIntervalSince1970 * 1000)
        let nbf = jti / 1000
        let exp = nbf + 60

        do {
            let goPlaySession =  AuthManager.shared.currentSesion()
            let jsonData: String
            if let json = try? JSONSerialization.data(withJSONObject: data),
               let jsonStr = String(data: json, encoding: .utf8) {
                jsonData = jsonStr
            } else {
                jsonData = String(describing: data)
            }
            
            
           
            let claims : PayLoadUserInfo = PayLoadUserInfo(
            
                sub: clientId,
//                aud: "access_token",
                exp: Int(exp),
                sid: 0,
                
                aty: UInt8(goPlaySession?.accountType ?? 1),//0: fast play, 1: goID, 2: Facebook, 3: Google, 4: Apple
                uid: goPlaySession?.userId ?? 0,
                name: goPlaySession?.userName ?? "",
//                dvId: "DEVICE_ID_001",
//                os: "iOS",
//                ip: "127.0.0.1",
//                sta: 5,
//                scopes: "sso auth update",
//                sso: 1
            )

            var jwt = JWT(claims: claims)
            let signedToken = await generateSignature(claims: claims)
            return signedToken
        } catch {
            return nil
        }
    }
}
