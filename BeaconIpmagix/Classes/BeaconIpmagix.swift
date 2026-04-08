//
//  BeaconIpmagix.swift
//  Pods
//
//  Created by Raouf on 24/03/2026.
//

import Foundation
import CoreLocation
import CoreBluetooth
import UserNotifications

public final class BeaconIpmagix: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    // MARK: - Properties
    public static let shared = BeaconIpmagix()
    private var k: String?
    private var locationManager: CLLocationManager?
    private var beaconRegions: [CLBeaconRegion] = []
    private var externalRegions: [RegionBeaconModel] = []
    private var notifiedUUIDs: [String: Date] = [:]
    private var triggeredUUIDs: Set<String> = []
    private let cooldownInterval: TimeInterval = 5.0

    private override init() {
        super.init()
    }

    // MARK: - Public API
    public func configure(appKey: String) {
        self.k = appKey
        BeaconLogger.shared.log("✅ SDK initialized")
        setupLocationManager()
        requestNotificationPermission()
    }

    public func getAppKey() -> String? {
        return k
    }

    public func isValid() -> Bool {
        return k != nil && !k!.isEmpty
    }

    public func isConfigured() -> Bool {
        return k != nil && !(k?.isEmpty ?? true)
    }

    // MARK: - Setup
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

        // 🔥 Keep scanning active continuously
        locationManager?.pausesLocationUpdatesAutomatically = false

        if #available(iOS 9.0, *) {
            locationManager?.allowsBackgroundLocationUpdates = true
        }

        // Start updating location to keep the app alive for beacon scanning
        locationManager?.startUpdatingLocation()
    }

    public func setBeaconsListAndStartScanning(_ regions: [RegionBeaconModel]) {
        self.externalRegions = regions
        startScanning(regions: regions)
    }

    public func getBeaconsList(completion: @escaping (Result<[RegionBeaconModel], Error>) -> Void) {
        guard !externalRegions.isEmpty else {
            completion(.failure(NSError(domain: "BeaconIpmagix", code: -1, userInfo: [NSLocalizedDescriptionKey: "No beacons provided. Use setBeaconsList(_:)"])))
            return
        }
        completion(.success(externalRegions))
    }

    // MARK: - Start Scanning (Public API)
    public func startScanning() {
        guard isConfigured() else {
            BeaconLogger.shared.log("❌ SDK not configured. Call configure(appKey:) first")
            return
        }
        startScanning(regions: self.externalRegions)
    }

    // MARK: - Scanning
    private func startScanning(regions: [RegionBeaconModel]) {
        guard let locationManager = locationManager else { return }

        for region in regions {
            if let uuid = UUID(uuidString: region.uuid) {
                let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: region.name)
                beaconRegions.append(beaconRegion)

                locationManager.startMonitoring(for: beaconRegion)
                locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: uuid))

                BeaconLogger.shared.log("📡 Scanning UUID: \(region.uuid)")
            }
        }
    }


    // MARK: - Stop Scanning (Public API)
    public func stopScanning() {
        guard let locationManager = locationManager else { return }

        for region in beaconRegions {
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: region.uuid))
        }

        beaconRegions.removeAll()
        BeaconLogger.shared.log("🛑 Stopped all beacon scanning")
    }

    public func stopScanning(for uuidBeacon: String) {
        guard let locationManager = locationManager,
              let uuid = UUID(uuidString: uuidBeacon) else { return }

        let constraint = CLBeaconIdentityConstraint(uuid: uuid)

        if let region = beaconRegions.first(where: { $0.uuid == uuid }) {
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(satisfying: constraint)
            beaconRegions.removeAll { $0.uuid == uuid }
            BeaconLogger.shared.log("🛑 Stopped scanning for UUID: \(uuidBeacon)")
        }
    }

    // MARK: - CLLocation Delegate
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            BeaconLogger.shared.log("✅ Location authorized")
        } else {
            BeaconLogger.shared.log("❌ Location denied")
        }
    }

    public func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {

        guard !beacons.isEmpty else { return }

        for beacon in beacons {
            BeaconLogger.shared.log("📍 Beacon detected: \(beacon.uuid.uuidString) RSSI: \(beacon.rssi)")

            let uuidString = beacon.uuid.uuidString

            // Check if beacon exists in provided externalRegions
            let isAllowed = externalRegions.contains { $0.uuid.uppercased() == uuidString.uppercased() }

            guard isAllowed else {
                BeaconLogger.shared.log("⛔️ Ignored beacon (not in list): \(uuidString)")
                continue
            }
            self.notifyUserWithCooldown(uuid: uuidString)
        }
        // 🔁 Force continuous ranging to avoid iOS throttling
//        manager.stopRangingBeacons(satisfying: beaconConstraint)
//        manager.startRangingBeacons(satisfying: beaconConstraint)
    }

    // MARK: - Beacon Region Monitoring (Killed State Support)
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else {
            BeaconLogger.shared.log("⚠️ Entered non-beacon region")
            return
        }

        let uuidString = beaconRegion.uuid.uuidString
        BeaconLogger.shared.log("🚪 Entered region UUID: \(uuidString)")

        // Check if this UUID exists in allowed external regions
        let isAllowed = externalRegions.contains { $0.uuid.uppercased() == uuidString.uppercased() }

        guard isAllowed else {
            BeaconLogger.shared.log("⛔️ Ignored region (not in list): \(uuidString)")
            return
        }

        self.notifyUserWithCooldown(uuid: uuidString)
        // 🔥 Restart ranging when entering region (important for background/killed state)
        if let beaconRegion = region as? CLBeaconRegion {
            let constraint = CLBeaconIdentityConstraint(uuid: beaconRegion.uuid)
            manager.startRangingBeacons(satisfying: constraint)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let beaconRegion = region as? CLBeaconRegion else {
            BeaconLogger.shared.log("⚠️ Entered non-beacon region")
            return
        }

        let uuidString = beaconRegion.uuid.uuidString
        triggeredUUIDs.remove(uuidString)
    }


    // MARK: - Permission Request
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                BeaconLogger.shared.log("✅ Notification permission granted")
            } else if let error = error {
                BeaconLogger.shared.log("❌ Permission error: \(error.localizedDescription)")
            } else {
                BeaconLogger.shared.log("⚠️ Notification permission DENIED — user must enable in Settings")
            }
        }
    }

    // MARK: - Fixed Fire Notification
    private func fireLocalNotification(body: String) {
        // ✅ Step 4: Always check authorization status before firing
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized ||
                    settings.authorizationStatus == .provisional else {
                BeaconLogger.shared.log("⚠️ Notifications not authorized: \(settings.authorizationStatus.rawValue)")
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Beacon Notification"
            content.body = body
            content.sound = .default

            // ✅ Interruption level for iOS 15+
            if #available(iOS 15.0, *) {
                content.interruptionLevel = .timeSensitive
                content.relevanceScore = 1.0
            }

            // ✅ Use 0.1 minimum safe delay (1s is fine too)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        BeaconLogger.shared.log("❌ Notification error: \(error.localizedDescription)")
                    } else {
                        BeaconLogger.shared.log("📢 Notification fired successfully")
                    }
                }
            }

            NotificationCenter.default.post(
                name: NSNotification.Name("BeaconIpmagix_Detected"),
                object: nil,
                userInfo: [
                    "body": body,
                ]
            )
        }
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // MARK: - Backend Validation
    private func notifyUser(uuid: String) {
        let requestStartTime = Date()

        guard let _ = k else {
            BeaconLogger.shared.log("please set api key first!")
            return
        }

        let url = URL(string: EndpointsBeacons.userNotify(beaconID: uuid))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(BaseBeaconApi.apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("\(BaseBeaconApi.token)", forHTTPHeaderField: "Authorization")

        // 🔍 Build cURL representation
        var curlCommand = "curl -X \(request.httpMethod ?? "POST") \"\(url.absoluteString)\""

        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                curlCommand += " \\\n  -H \"\(key): \(value)\""
            }
        }

        BeaconLogger.shared.log("📤 REQUEST (cURL):\n\(curlCommand)")
        BeaconLogger.shared.log("🕒 Request Time: \(requestStartTime)")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            let responseTime = Date()
            let duration = responseTime.timeIntervalSince(requestStartTime)

            guard let data = data else {
                BeaconLogger.shared.log("❌ No data received")
                BeaconLogger.shared.log("🕒 Response Time: \(responseTime)")
                BeaconLogger.shared.log("⏱ Duration: \(duration)s")
                return
            }

            do {
                let result = try JSONDecoder().decode(NotifyUserBeaconResponse.self, from: data)
                BeaconLogger.shared.log("📥 RESPONSE:")
                BeaconLogger.shared.log("🔐 Data: \(result.data)")
                BeaconLogger.shared.log("✅ Success: \(result.success)")
                BeaconLogger.shared.log("💬 Message: \(result.message)")
                BeaconLogger.shared.log("🕒 Response Time: \(responseTime)")
                BeaconLogger.shared.log("⏱ Duration: \(duration)s")
                if result.success {
                    self.fireLocalNotification(body: result.data)
                } else {
                    BeaconLogger.shared.log("❌ API failed: \(result.message)")
                    BeaconLogger.shared.log("🕒 Response Time: \(responseTime)")
                    BeaconLogger.shared.log("⏱ Duration: \(duration)s")
                }
            } catch {
                BeaconLogger.shared.log("❌ Decoding error: \(error.localizedDescription)")

                // 🔍 Log raw response to debug backend issues
                if let rawString = String(data: data, encoding: .utf8) {
                    BeaconLogger.shared.log("📄 Raw Response: \(rawString)")
                }
                BeaconLogger.shared.log("🕒 Response Time: \(responseTime)")
                BeaconLogger.shared.log("⏱ Duration: \(duration)s")

                // ✅ IMPORTANT: Do NOT block scanning or logic on decoding failure
                // Just skip and continue normal beacon scanning
            }
        }.resume()
    }

    private func notifyUserWithCooldown(uuid: String) {
        // 🚫 If already triggered, skip — removal after 5s handles the re-trigger window
        guard !triggeredUUIDs.contains(uuid) else {
            BeaconLogger.shared.log("⚠️ UUID \(uuid) already triggered. Waiting for cooldown.")
            return
        }

        // ✅ Mark as triggered and call API
        triggeredUUIDs.insert(uuid)
        BeaconLogger.shared.log("✅ Triggering notify for UUID: \(uuid)")
        notifyUser(uuid: uuid)

        // 🕐 After 5s, remove so it can fire again if beacon is still in range
        DispatchQueue.main.asyncAfter(deadline: .now() + cooldownInterval) {
            self.triggeredUUIDs.remove(uuid)
            BeaconLogger.shared.log("🔓 Cooldown expired for UUID: \(uuid). Ready to re-trigger.")
        }
    }

}
