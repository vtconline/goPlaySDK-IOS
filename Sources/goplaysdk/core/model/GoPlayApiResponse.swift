public struct GoPlayApiResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?

    func isSuccess() -> Bool {
        return code == GoErrorCode.Authen.ok.rawValue
    }

    func haveError() -> Bool {
        return code != 0
    }

    func tokenExpired() -> Bool {
        return code == GoErrorCode.Authen.expired.rawValue && message == "token_expired"
    }
}
