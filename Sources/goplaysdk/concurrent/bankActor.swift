//
//  bankActor.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 17/4/25.
//

import Foundation


 
/// Để sử dụng một actor, bạn cần gọi các phương thức của actor từ một task bất đồng bộ (asynchronous task)
/// Mọi truy cập vào actor phải được thực hiện thông qua các hàm async hoặc thông qua await để đảm bảo tính đồng bộ
/// 
actor BankAccount {
    private var balance: Double = 0.0
    
    // Hàm để nạp tiền vào tài khoản
    func deposit(amount: Double) {
        balance += amount
    }
    
    // Hàm để rút tiền khỏi tài khoản
    func withdraw(amount: Double) -> Bool {
        if balance >= amount {
            balance -= amount
            return true
        } else {
            return false
        }
    }
    
    // Hàm để kiểm tra số dư tài khoản
    func getBalance() -> Double {
        return balance
    }
}
