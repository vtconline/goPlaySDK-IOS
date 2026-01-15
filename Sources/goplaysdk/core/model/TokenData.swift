

public struct TokenData: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let deviceId: String
    let timeserver: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case deviceId
        case timeserver
    }
    
    // Custom decoding to default deviceId to an empty string if it's null
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the required fields
        self.accessToken = try container.decode(String.self, forKey: .accessToken) ?? ""
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken) ?? ""
        // Handle expiresIn with default value of 0 if null
        self.expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn) ?? 0
        
        // Handle deviceId with default empty string if null
        self.deviceId = try container.decodeIfPresent(String.self, forKey: .deviceId) ?? ""
        
        // Handle timeserver with default value of 0 if null
        self.timeserver = try container.decodeIfPresent(Int.self, forKey: .timeserver) ?? 0
    }
}
