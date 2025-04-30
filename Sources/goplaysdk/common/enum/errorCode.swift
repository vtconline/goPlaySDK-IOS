
enum GoPlayError: Error {
    case outOfPaper
    case noToner
    case onFire
}

enum GoErrorCode {
    enum Authen: Int {
        case ok = 0
        case missingParameter = 81
        case expired = 86
        case codeUnknown = 99
        case phoneNotValidated = 208
        case emailNotValidated = 407
        case unknown = -99

        static func from(value: Int) -> Authen {
            return Authen(rawValue: value) ?? .unknown
        }
    }
}

//example
//do {
//    .....
//    throw GoPlayError.noToner
//    print(printerResponse)
//} catch GoPlayError.onFire {
//    print("I'll just put this over here, with the rest of the fire.")
//} catch let printerError as GoPlayError {
//    print("Printer error: \(printerError).")
//} catch {
//    print(error)
//}
