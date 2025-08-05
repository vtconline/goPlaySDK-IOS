//import Foundation
//import CryptoKit
//import JWTKit
//
//@MainActor
//class ApiService {
//    private var baseURL = GoApi.apiProduct  //GoApi.apiProduct
//    
//    public let clientId: String = "29658d7cd198458a" // Au2  2025==>29658d7cd198458a  2020:2356aa1f65af420c
//    public let clientSecret: String = "63/k6+G2LQVrFUOUOMvPzhz2scuwlBSrPMq+8UpMBRfTuWVGL+Aa2Q5i7rLzIy20" // 2025==>63/k6+G2LQVrFUOUOMvPzhz2scuwlBSrPMq+8UpMBRfTuWVGL+Aa2Q5i7rLzIy20  2024 ==>SwlDJHfkE8F8ldQr9wzwDF6jTMRG6+/5
//    
//    // Signs and verifies JWTs
//    let keys = JWTKeyCollection()
//    
//    static let shared = ApiService()
//    private init()  {
//        
//    }
//    
//    private var isInitialized = false  // Flag to check if initialization is done
//    // This async function will handle the initialization.
//    func initJwtIfNeeded() async {
//        guard !isInitialized else { return }  // Only run this once
//        
//        isInitialized = true
//        print("Initializing JWT keys...")
//        
//        // Perform your async JWT setup here
//        await keys.add(hmac: HMACKey(from: Data(clientSecret.utf8)), digestAlgorithm: .sha256)
//        // Optionally, add other keys with different configurations
//        // await keys.add(hmac: "secret", digestAlgorithm: .sha256, kid: "my-key")
//        
//        print("JWT initialization complete.")
//    }
//    
//    
//    // Add your token retrieval logic here
//    private var bearerToken: String? {
//        // For example, from UserDefaults or Keychain
//        return nil
//    }
//    
//    func setBaseURL(_ newBaseURL: String) {
//        self.baseURL = newBaseURL
//    }
//    
//    // MARK: - Public GET Request
//    func get(path: String, sign: Bool = true, completion: @escaping (Result<Data, Error>) -> Void) async {
//        await request(method: "GET", path: path, sign: sign, completion: completion)
//    }
//    
//    // MARK: - Public POST Request
//    func post(path: String, body: [String: Any], sign: Bool = true, useAcessToken:Bool = false, completion: @escaping (Result<Data, Error>) -> Void) async {
//        await request(method: "POST", path: path, body: body, sign: sign, completion: completion)
//    }
//    
//    // MARK: - Private Core Request Method
//    private func request(
//        method: String,
//        path: String,
//        body: [String: Any]? = nil,
//        sign: Bool = false,
//        completion: @escaping (Result<Data, Error>) -> Void
//    ) async {
//        guard let url = URL(string: "\(baseURL)\(path)") else {
//            print("Invalid URL")
//            return
//        }
//        print("url URL \(url)")
//        // Ensure JWT is initialized before making the request
//        await initJwtIfNeeded()
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        
//        var bodyParams : [String: Any] = [:]
//        var bodyMerge: [String: Any]? = body  // Let's assume body is provided earlie
//        
//        
//        if method == "POST", var requestBody = bodyMerge {
//            if sign {
//                // Append data from getPartnerParams to requestBody
//                
//                if var mergedBody = bodyMerge {
//                
//                    let partnerParams = Utils.getPartnerParams()
//                    mergedBody = mergedBody.merging(partnerParams) { current, _ in current }
//
//                    // Update the bodyMerge to the mergedBody
//                    bodyMerge = mergedBody
//                }
//                print("requestBody before jwt \(requestBody)")
//                bodyParams["jwt"] = await generateSignature(data: requestBody) ?? ""
//            } else {
//                bodyParams["jwt"] = KeychainHelper.loadCurrentSession()?.accessToken ?? ""
//                bodyParams["cid"] = clientId
//                bodyParams["clientId"] = clientId //old version
//                bodyParams = bodyParams.merging(bodyMerge ?? [:]) { current, _ in current }
//            }
//            
//            if let token = bearerToken {
//                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//            }
//            
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
//                request.httpBody = jsonData
//            } catch {
//                completion(.failure(error))
//                return
//            }
//        }
//        
//        let task = URLSession.shared.dataTask(with: request) { data, _, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            if let data = data {
//                completion(.success(data))
//            } else {
//                let error = NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
//                completion(.failure(error))
//            }
//        }
//        
//        task.resume()
//    }
//    
//    // MARK: - Helper: Generate Signature
//    
//    // Define the JWT payload outside the function to avoid redefining
//    struct MyPayload: JWTPayload {
//        func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
//            
//        }
//        
//        var jti: String
//        var iss: String
//        var nbf: Int
//        var exp: Int
//        var sid: Int
//        var jdt: String
//        
//        //        func verify(using signer: JWTSigner) throws {
//        //            // Optional: Verify expiration or not-before if needed
//        //        }
//    }
//    
//    struct ExamplePayload: JWTPayload {
//        var sub: SubjectClaim
//        var exp: ExpirationClaim
//        var admin: BoolClaim
//        
//        func verify(using key: some JWTAlgorithm) throws {
//            try self.exp.verifyNotExpired()
//        }
//    }
//    
//    func generateSignature( data: Any) async -> String?{
//        let jti = Int64(Date().timeIntervalSince1970 * 1000)
//        let nbf = jti / 1000
//        let exp = nbf + 60
//        
//        
//        do {
//            
//            
//            // Serialize data to a JSON string, or fallback to description
//            let jsonData: String
//            if let json = try? JSONSerialization.data(withJSONObject: data),
//               let jsonStr = String(data: json, encoding: .utf8) {
//                jsonData = jsonStr
//            } else {
//                jsonData = String(describing: data)
//            }
//            
//            // Create JWT payload
//            let payload = MyPayload(
//                jti: String(jti),
//                iss: clientId,
//                nbf: Int(nbf),
//                exp: Int(exp),
//                sid: 0,
//                jdt: jsonData
//            )
//            
//            // Sign JWT
//            // Sign the payload, returning the JWT as String
//            let jwt = try await keys.sign(payload)//, kid: "my-key"
////            print("jwt \(jwt)")
//            
//            return jwt
//            
//        } catch {
//            print(error)
//            
//        }
//        return nil
//    }
//}
