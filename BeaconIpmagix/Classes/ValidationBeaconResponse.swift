//
//  BeaconIpmagix.swift
//  Pods
//
//  Created by Raouf on 24/03/2026.
//

import Foundation

struct ValidationBeaconResponse: Codable {
    let valid: Bool
}


struct NotifyUserBeaconResponse: Codable {
    let success: Bool
    let message: String
    let timestamp: String
    let data: String
}
