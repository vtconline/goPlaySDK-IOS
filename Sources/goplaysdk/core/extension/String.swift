import Foundation

extension String {
    var isNullOrEmpty: Bool {
        return self.isEmpty
    }

    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString)
    }

    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension Optional where Wrapped == String {
    var isNullOrEmpty: Bool {
        return self?.isEmpty ?? true
    }

    var isBlank: Bool {
        return self?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
}
