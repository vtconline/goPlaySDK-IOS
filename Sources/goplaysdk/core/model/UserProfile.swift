//
//  UserProfile.swift
//  goplaysdk
//
//  Created by pate on 14/1/26.
//


public struct UserProfile: Codable, Equatable, Sendable {
    public let userId: Int
        public let accountName: String?
        public let fullName: String?
        public let email: String?
        public let phone: String?

        public let confirmCode: Int
        public let canRename: Bool
        public let status: Int

        public let isMobileVerified: Bool
        public let isEmailVerified: Bool
        public let isMobileFirstVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "AccountID"
        case accountName = "AccountName"
        case phone = "Mobile"
        case email = "Email"
        case fullName = "Fullname"
        case confirmCode = "ConfirmCode"
        case status = "Status"
        case canRename
        case isMobileVerified
        case isEmailVerified
        case isMobileFirstVerified
//        case Passport
//        case timeserver
    }


    
    // Custom decoding to default deviceId to an empty string if it's null
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the required fields
        self.userId = try container.decodeIfPresent(Int.self, forKey: .userId) ?? 0
        self.accountName = try container.decodeIfPresent(String.self, forKey: .accountName) ?? ""
        
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        // Handle expiresIn with default value of 0 if null
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        
        // Handle deviceId with default empty string if null
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        
        self.confirmCode = try container.decodeIfPresent(Int.self, forKey: .confirmCode) ?? 0
        
        self.canRename = try container.decodeIfPresent(Bool.self, forKey: .canRename) ?? false
        self.status = try container.decodeIfPresent(Int.self, forKey: .status) ?? 0
        
        self.isMobileVerified = try container.decodeIfPresent(Bool.self, forKey: .isMobileVerified) ?? false
        self.isEmailVerified = try container.decodeIfPresent(Bool.self, forKey: .isEmailVerified) ?? false
        self.isMobileFirstVerified = try container.decodeIfPresent(Bool.self, forKey: .isMobileFirstVerified) ?? false
    }
}
