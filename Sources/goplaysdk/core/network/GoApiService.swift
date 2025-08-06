import Foundation
import SwiftJWT

@MainActor
public class GoApiService {
   
    
    public static let shared = GoApiService()
    private init() {}

//    private var isInitialized = false
//    private var signer: JWTSigner?

    public func getuserParams(_ jwtToken: String?) -> [String: Any] {
        
        
        var jToken = jwtToken;
        var params : [String: Any] = [:]// Utils.getPartnerParams()
        
        if jToken == nil || jToken == "" {
                    jToken = KeychainHelper.loadCurrentSession()?.accessToken ?? "";
        }
        params["jwt"] = jToken;
        params["clientId"] = ApiService.shared.clientId;
        params["cid"] = ApiService.shared.clientId;
            
        return params
    }

    
    public func dictionaryToString(_ dict: [String: Any]) -> String {
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }
    public func getRemoteConfig(success: @escaping ([String: Any]) -> Void, failure: @escaping (_ error : Error ) -> Void) {
        LoadingDialog.instance.show()
        // This would be a sample data payload to send in the POST request
        var bodyData: [String: Any] = Utils.getPartnerParams()
    
        Task {
            await ApiService.shared.post(
                path: GoApi.oauthConfig,
                body: bodyData,
                sign: true
            ) { result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response

                    // Parse the response if necessary
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        guard let responseDict = jsonResponse as? [String: Any] else {
                            print("❌ getRemoteConfig JSON is not a dictionary")
                            return
                        }
                        print("✅ getRemoteConfig Parsed Response:", responseDict)
                        success(responseDict)
                    } catch {
                        print("❌ getRemoteConfig Failed to parse JSON:", error)
                    }

                case .failure(let error):
                    // Handle failure response
                    // print("Error: \(error.localizedDescription)")
                    AlertDialog.instance.show(
                        message: error.localizedDescription
                    )
                    failure(error)
                }
            }
        }
    }
    //checkDevice
    
    public func checkDevice(success: @escaping ([String: Any]) -> Void, failure: @escaping (_ error : Error) -> Void) {
        
        var refreshToken: String? = KeychainHelper.loadCurrentSession()?.refreshToken ?? "";
        print("checkDevice with refreshToken: \(refreshToken ?? "") ")
        var params = GoApiService.shared.getuserParams(refreshToken)
        LoadingDialog.instance.show()
        
    
        Task {
            await ApiService.shared.post(
                path: GoApi.oauthDeviceLogin,
                body: params,
                sign: false
            ) { result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response

                    // Parse the response if necessary
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        guard let responseDict = jsonResponse as? [String: Any] else {
                            print("❌ checkDevice JSON is not a dictionary")
                            return
                        }
                        print("✅ checkDevice Parsed Response:", responseDict)
                        success(responseDict)
                    } catch {
                        print("❌ checkDevice Failed to parse JSON:", error)
                    }

                case .failure(let error):
                    // Handle failure response
                    // print("Error: \(error.localizedDescription)")
                    AlertDialog.instance.show(
                        message: error.localizedDescription
                    )
                    failure(error)
                }
            }
        }
    }
}
