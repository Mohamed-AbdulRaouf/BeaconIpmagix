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

    private func validateWithServer() {
        guard let key = appKey else { return }

        let url = URL(string: "https://yourapi.com/sdk/validate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = ["appKey": key]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }

            if let result = try? JSONDecoder().decode(ValidationResponse.self, from: data) {
                debugPrint(result.valid)
            }
        }.resume()
    }

}
