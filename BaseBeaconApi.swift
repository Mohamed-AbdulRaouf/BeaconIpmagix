//
//  BaseBeaconApi.swift
//  BeaconIpmagix
//
//  Created by Raouf on 24/03/2026.
//

import Foundation

final public class BaseBeaconApi {

    public static let apiKey: String = "Jn5oAmlYaFs@91qATftOzQB8XQHdVOycSu2X2g4JZZkiMEa2G1GqXq9FTPo1jh#K"

    static var baseUrl: String {
        return "https://whatsappapidemo.azurewebsites.net"
    }

    static var token: String {
        return "Bearer \(UserDefaults.standard.string(forKey: "authToken") ?? "")"
    }
}
