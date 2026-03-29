//
//  LoginRequest.swift
//  BeaconIpmagix
//
//  Created by Raouf on 29/03/2026.
//  Copyright © 2026 CocoaPods. All rights reserved.
//
import Foundation

struct LoginRequest: Codable {
    let userName: String
    let password: String
}

struct LoginResponseModel: Codable {
    let success: Bool
    let message: String
    let timestamp: String
    let data: LoginData?
}

struct LoginData: Codable {
    let userId: String
    let displayName: String
    let token: String
    let beacons: [String]
}
