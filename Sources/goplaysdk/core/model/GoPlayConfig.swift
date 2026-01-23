import Foundation
public struct GoPlayConfig: Decodable {
    public let redirectUrl: String?
    public let tokenExpired: Bool?
    public let haveError: Bool?
    public let message: String?
    public let nextStep: Int?
    public let isSuccessed: Bool?
    public let code: Int?
    public let data: ConfigData?

    enum CodingKeys: String, CodingKey {
        case redirectUrl
        case tokenExpired = "token_expired"
        case haveError = "HaveError"
        case message
        case nextStep
        case isSuccessed = "IsSuccessed"
        case code
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.redirectUrl = try? container.decodeIfPresent(String.self, forKey: .redirectUrl)
        self.tokenExpired = try? container.decodeFlexibleBool(forKey: .tokenExpired)
        self.haveError = try? container.decodeFlexibleBool(forKey: .haveError)
        self.message = try? container.decodeIfPresent(String.self, forKey: .message)
        self.nextStep = try? container.decodeIfPresent(Int.self, forKey: .nextStep)
        self.isSuccessed = try? container.decodeFlexibleBool(forKey: .isSuccessed)
        self.code = try? container.decodeIfPresent(Int.self, forKey: .code)
        self.data = try? container.decodeIfPresent(ConfigData.self, forKey: .data)
    }

    public struct ConfigData: Codable {
        public let ap_AppId: String?
        public let baseUrl: String?
        public let clientName: String?
        public let fastplay: Int?
        public let fb_AppId: String?
        public let fb_AppKey: String?
        public let gg_clientId: String?
        public let gg_clientSecret: String?
        public let goCfg: String?
        public let loginByEmail: Int?
        public let loginbyPhone: Int?
    }

    public var googleClientId: String {
        return data?.gg_clientId ?? ""
    }
}

extension KeyedDecodingContainer {
    func decodeFlexibleBool(forKey key: K) throws -> Bool {
        if let boolValue = try? decode(Bool.self, forKey: key) {
            return boolValue
        }
        if let intValue = try? decode(Int.self, forKey: key) {
            return intValue != 0
        }
        if let strValue = try? decode(String.self, forKey: key) {
            return (strValue == "true" || strValue == "1")
        }
        throw DecodingError.typeMismatch(
            Bool.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Cannot decode as Bool/Int/String")
        )
    }
}

