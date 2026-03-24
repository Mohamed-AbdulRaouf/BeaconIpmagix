//
//  BeaconIpmagix.swift
//  Pods
//
//  Created by Raouf on 24/03/2026.
//

import Foundation

public class BeaconIpmagix {

    public static let shared = BeaconIpmagix()

    private var appKey: String?

    private init() {}

    public func configure(appKey: String) {
        self.appKey = appKey
        debugPrint("✅ SDK initialized with appKey: \(appKey)")
    }

    public func getAppKey() -> String? {
        return appKey
    }

    public func isValid() -> Bool {
        return appKey != nil && !appKey!.isEmpty
    }

}
