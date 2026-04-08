//
//  BeaconLogger.swift
//  BeaconIpmagix
//
//  Created by Raouf on 30/03/2026.
//

import Foundation
import Combine

public final class BeaconLogger: ObservableObject {
    public static let shared = BeaconLogger()

    @Published public private(set) var logs: [String] = []

    private init() {}

    public func log(_ message: String) {
        DispatchQueue.main.async {
            self.logs.append(message)
            print(message)
        }
    }

    public func clear() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }
}
