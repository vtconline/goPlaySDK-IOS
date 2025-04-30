public enum AccountType: Int {
    case goId = 1
    case guest = 21
    case emailAndPhoneActive = 5
    case google = 31
    case fb = 51
    case apple = 61
    case phone = 71
    case email = 81
    case unknown = -99

    static func from(_ value: Int) -> AccountType {
        return AccountType(rawValue: value) ?? .unknown
    }
}
public enum ConfirmCode: Int {
    case emailActive = 1
    case phoneActive = 2
    case emailAndPhoneActive = 5
    case unknown = -99

    static func from(_ value: Int) -> ConfirmCode {
        return ConfirmCode(rawValue: value) ?? .unknown
    }
}

enum Suit {
    case spades, hearts, diamonds, clubs


    func simpleDescription() -> String {
        switch self {
        case .spades:
            return "spades"
        case .hearts:
            return "hearts"
        case .diamonds:
            return "diamonds"
        case .clubs:
            return "clubs"
        }
    }
}
//let hearts = Suit.hearts
//let heartsDescription = hearts.simpleDescription()

enum Rank: Int {
    case ace = 1
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king


    func simpleDescription() -> String {
        switch self {
        case .ace:
            return "ace"
        case .jack:
            return "jack"
        case .queen:
            return "queen"
        case .king:
            return "king"
        default:
            return String(self.rawValue)
        }
    }
}

struct Card {
    var rank: Rank
    var suit: Suit
    func simpleDescription() -> String {
        return "The \(rank.simpleDescription()) of \(suit.simpleDescription())"
    }
}
//let threeOfSpades = Card(rank: .three, suit: .spades)
//let threeOfSpadesDescription = threeOfSpades.simpleDescription()


