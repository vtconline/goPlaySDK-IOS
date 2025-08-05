

public enum GoApi {
    
    static let apiSandbox = "https://dev-api.goplay.vn/core/v1/"
    static let apiProduct = "https://api.goplay.vn/core/v1/"
    static let oauthConfig = "authen-service/oauth/getconfig"
    static let oauthCheckAuthenOtp = "authen-service/oauth/checkauthenotp"
    static let oauthGetAuthenOtp = "authen-service/oauth/getauthenOtp"
    static let oauthLogin = "authen-service/oauth/login"
    static let oauthRegister = "authen-service/oauth/register"
    static let oauthDeviceLogin = "authen-service/oauth/devicelogin"
    static let oauthLogout = "authen-service/oauth/logout"
    static let oauthGoogle = "authen-service/oauth/logingoogle"
    static let oauthFacebook = "authen-service/oauth/loginfacebook"
    static let oauthGuest = "authen-service/oauth/loginfast"
    static let oauthApple = "authen-service/oauth/loginapple"
    static let getInfo = "authen-service/users/get/info"
    static let getUserInfo = "authen-service/users/get/userinfo"
    static let oauthToken = "authen-service/oauth/token"
    static let verifyPhone = "authen-service/users/v3/update/verifyphone"
    static let userRename = "authen-service/users/update/rename"
}
