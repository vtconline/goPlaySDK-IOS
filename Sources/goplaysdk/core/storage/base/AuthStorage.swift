//
//  AuthStorage.swift
//  goplaysdk
//
//  Created by pate on 14/1/26.
//


public protocol AuthStorage: Sendable {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    func clear()
}