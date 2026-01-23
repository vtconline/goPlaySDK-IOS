public struct GoPlayApiResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
    let mustActive: Int?
    let nextStep: Int?
    
    static func createTest(
            code: Int = GoErrorCode.Authen.ok.rawValue,
            message: String = "success",
            data: T? = nil,
            mustActive: Int? = 0
        ) -> GoPlayApiResponse<T> {
            return GoPlayApiResponse(
                code: code,
                message: message,
                data: data,
                mustActive: mustActive,
                nextStep: nil
            )
        }

    func isSuccess() -> Bool {
        return code == GoErrorCode.Authen.ok.rawValue
    }

    func haveError() -> Bool {
        return code != 0
    }
    
    func isMustActive() -> Bool {
        return mustActive != nil && mustActive == 1
    }

    func tokenExpired() -> Bool {
        return code == GoErrorCode.Authen.expired.rawValue && message == "token_expired"
    }
}
