//
//  textFieldValidator.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 24/4/25.
//
import SwiftUI
//protocol TextFieldValidator {
//    var isValid: Bool { get set }
//    func validate(text: String) -> (isValid: Bool, errorMessage: String)
//    var errorMessage: String { get }
//}
class TextFieldValidator: ObservableObject {
    @Published var isValid: Bool = true
    @Published var errorMessage: String = ""
    
    func validate(text: String) -> (isValid: Bool, errorMessage: String){
        return (true, "")
    }

}
