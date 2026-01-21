import Foundation
import SwiftJWT

//@MainActor
public class GoApiService: @unchecked Sendable {
   
    
    public static let shared = GoApiService()
    private init() {}

//    private var isInitialized = false
//    private var signer: JWTSigner?

    @MainActor
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
    public func getRemoteConfig(success: @MainActor @escaping ([String: Any]) -> Void, failure:@MainActor @escaping (_ error : Error ) -> Void) async {
//        LoadingDialog.instance.show()
        // This would be a sample data payload to send in the POST request
        
    
            await ApiService.shared.post(
                path: GoApi.oauthConfig,
                bodyJwtSign: [:]
            ) { result in

//                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response
                    KeychainHelper.save(key: "vtc_remoteConfig", data: data)
                    // Parse the response if necessary
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        guard let responseDict = jsonResponse as? [String: Any] else {
                            print("❌ getRemoteConfig JSON is not a dictionary")
                            return
                        }
//                        print("✅ getRemoteConfig Parsed Response:", responseDict)
                        
                        Task { @MainActor in
                            success(responseDict)
                        }
                    } catch {
                        print("❌ getRemoteConfig Failed to parse JSON:", error)
                    }

                case .failure(let error):
                    if let dataSave = KeychainHelper.load(key: "vtc_remoteConfig") {
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: dataSave, options: [])
                            if let dict = jsonObject as? [String: Any] {
                                print("Loaded remoteConfig:", dict)
                               
                                Task { @MainActor in
                                    success(dict)
                                }
                            } else {
                                print("Loaded data is not a dictionary")
                            }
                        } catch {
                            print("Failed to parse remoteConfig from Keychain:", error)
//                            AlertDialog.instance.show(
//                                message: "Không tải được cấu hình từ server"
//                            )
                            
                            Task { @MainActor in
                                failure(error)
                            }
                        }
                    } else {
                        // Không lấy được trong Keychain → trả về null / nil
//                        print("No remoteConfig found in Keychain")
//                        AlertDialog.instance.show(
//                            message: "Không tải được cấu hình từ server"
//                        )
                        Task { @MainActor in
                            failure(error)
                        }
                        
                    }
                    
                
                    // Handle failure response
                    // print("Error: \(error.localizedDescription)")
                    
                }
            
        }
    }
    
    public func getUserInfo(callback: @escaping @Sendable (UserProfile?) -> Void)  {
        

        

        // Now, you can call the `post` method on ApiService
        Task { @MainActor in
            let bodyData: [String: Any] =  getuserParams(nil)
            await ApiService.shared.post(path: GoApi.getInfo, body: bodyData) { result in

                LoadingDialog.instance.hide()

                switch result {
                case .success(let data):
                    // Handle successful response
                    do{
                        
                        if let jsonResponse = try? JSONSerialization.jsonObject(
                            with: data, options: []),
                            let responseDict = jsonResponse as? [String: Any]
                        {
//                            print("submitLoginPhone Response: \(responseDict)")
                            let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                                print("RAW JSON:", jsonString)
                            }
                            let profile =  try JSONDecoder().decode(
                                GoPlayApiResponse<UserProfile>.self, from: jsonData)
                             callback( profile.data)
                        }
                       
                    }catch {
                        print("error \(error.localizedDescription)")
                    }

                case .failure(let error):
                    // Handle failure response
                    //                    print("Error: \(error.localizedDescription)")
                    Task{
                        await AlertDialog.instance.show(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    public func checkDevice(success:@MainActor @escaping ([String: Any]) -> Void, failure:@MainActor @escaping (_ error : Error) -> Void) async {
        Task{@MainActor in
            var refreshToken: String? = KeychainHelper.loadCurrentSession()?.refreshToken ?? "";
//            print("checkDevice with refreshToken: \(refreshToken ?? "") ")
            if(refreshToken == nil  || refreshToken == "" ){
                let error = NSError(domain: "CheckDevice", code: -1, userInfo: [NSLocalizedDescriptionKey: "refreshToken sent is empty"])
                Task { @MainActor in
                    failure(error)
                }
                return;
            }
            var params = await GoApiService.shared.getuserParams(refreshToken)
            LoadingDialog.instance.show()
            
        
            
                await ApiService.shared.post(
                    path: GoApi.oauthDeviceLogin,
                    body: params,
                    
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
//                            print("✅ checkDevice Parsed Response:", responseDict)
                            
                            success(responseDict)
                        } catch {
                            print("❌ checkDevice Failed to parse JSON:", error)
                        }

                    case .failure(let error):
                        // Handle failure response
                        // print("Error: \(error.localizedDescription)")
    //                    AlertDialog.instance.show(
    //                        message: error.localizedDescription
    //                    )
                        
                        failure(error)
                        
                    }
                
            }
        }
        
    }
    
    public func logOut(success:@MainActor @escaping ([String: Any]) -> Void, failure:@MainActor @escaping (_ error : Error) -> Void) async {
        Task { @MainActor in
            var params = await GoApiService.shared.getuserParams("")
            LoadingDialog.instance.show()
            
            await ApiService.shared.post(
                    path: GoApi.oauthLogout,
                    body: params,
                    
                ) { result in

                    LoadingDialog.instance.hide()

                    switch result {
                    case .success(let data):
                        // Handle successful response

                        // Parse the response if necessary
                        do {
                            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                            guard let responseDict = jsonResponse as? [String: Any] else {
                                print("❌ logOut JSON is not a dictionary")
                                return
                            }
                            print("✅ logOut Parsed Response:", responseDict)
                            success(responseDict)
                            
                        } catch {
                            print("❌ logOut Failed to parse JSON:", error)
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
