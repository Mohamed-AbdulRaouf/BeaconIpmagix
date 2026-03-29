//
//  Endpoints.swift
//  BeaconIpmagix
//
//  Created by Raouf on 24/03/2026.
//

import Foundation

final public class EndpointsBeacons {


    public static let userLogin: String = "\(BaseBeaconApi.baseUrl)/api/v1/qnb/user/login"

    static func userNotify(beaconID: String) -> String {
        return "\(BaseBeaconApi.baseUrl)/api/v1/qnb/user/notify/\(beaconID)"
    }

}
