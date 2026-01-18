enum LoginType: Int {
    case auto = -1       // SERVER auto detect
    case goId = 0        // server fix
    case phone = 1       // server fix
    case email = 2       // user -1 better, 2 seem not work
    case google = 10
    case guest = 20
    case unknown = -99   // fallback

    static func from(_ value: Int) -> LoginType {
        return LoginType(rawValue: value) ?? .unknown
    }
}
