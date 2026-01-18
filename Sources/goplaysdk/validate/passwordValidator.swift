//
//  passwordValidator.swift
//  goplaysdk
//
//
//

class PasswordValidator: TextFieldValidator {
    let minLength: Int
    let maxLength: Int
    init(minLength: Int = 8, maxLength: Int = 20) {
            self.minLength = minLength
            self.maxLength = maxLength
        }

    

    override func validate(text: String) -> (isValid: Bool, errorMessage: String) {

        // 1️⃣ Check length
        guard text.count >= minLength && text.count <= maxLength else {
            return (
                false,
                "Mật khẩu phải dài từ \(minLength) đến \(maxLength) ký tự."
            )
        }

        // 2️⃣ Ít nhất 1 chữ thường
        let hasLowercase = text.rangeOfCharacter(from: .lowercaseLetters) != nil
        guard hasLowercase else {
            return (false, "Mật khẩu phải chứa ít nhất 1 chữ thường.")
        }

        // 3️⃣ Ít nhất 1 chữ hoa
        let hasUppercase = text.rangeOfCharacter(from: .uppercaseLetters) != nil
        guard hasUppercase else {
            return (false, "Mật khẩu phải chứa ít nhất 1 chữ hoa.")
        }

        // 4️⃣ Ít nhất 1 chữ số
        let hasDigit = text.rangeOfCharacter(from: .decimalDigits) != nil
        guard hasDigit else {
            return (false, "Mật khẩu phải chứa ít nhất 1 chữ số.")
        }

        // ✅ Pass tất cả
        return (true, "")
    }
}
