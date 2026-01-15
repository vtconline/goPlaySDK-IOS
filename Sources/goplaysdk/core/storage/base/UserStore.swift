//
//  UserStore.swift
//  goplaysdk
//
//  Created by pate on 14/1/26.
//


public protocol UserStore {
    func save(_ profile: UserProfile)
    func load() -> UserProfile?
    func clear()
}
