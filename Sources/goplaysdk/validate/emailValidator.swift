//
//  email.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 17/4/25.
//

import Foundation

class EmailValidator: TextFieldValidator {
    override func validate(text: String) -> (isValid: Bool, errorMessage: String) {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        isValid =  emailTest.evaluate(with: text)
        errorMessage = isValid ? "" : "Email không đúng định dạng"
        return (isValid, isValid ? "" : "abc")
    }
}
