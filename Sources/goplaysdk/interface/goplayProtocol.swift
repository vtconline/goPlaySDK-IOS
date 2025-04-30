//
//  goplayProtocol.swift
//  goplaysdk
//
//  Created by Ngô Đồng on 17/4/25.
//

protocol GoPlayProtocol {
     var simpleDescription: String { get }
     mutating func loginSuccess()
    mutating func loginFail(error: String)
    mutating func loginCancel(reasion: String?)
}
