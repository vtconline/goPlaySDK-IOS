/// <summary>
/// nextStep: 0: Do nothing, 1: Register Account, 2: Login With OTP , 3: Login With Password (usernam =Tel, Email, username),
/// 4: Login with password must input username, 5: Must update password
/// </summary>
enum GoNextStep: Int {
    case doNothing = 0
    case registerAccount = 1
    case loginWithOTP = 2
    case loginWithPwd = 3
    case loginWithPwdAndUserName = 4
    case mustUpdatePwd = 5
    case unknown = -99   // fallback

    static func from(_ value: Int) -> LoginType {
        return LoginType(rawValue: value) ?? .unknown
    }
}
