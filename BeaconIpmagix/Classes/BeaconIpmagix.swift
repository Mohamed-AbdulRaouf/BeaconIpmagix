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
    private let cooldownInterval: TimeInterval = 5.0

    private override init() {
        super.init()
    }

    // MARK: - Public API
    public func configure(appKey: String) {
        self.k = appKey
        debugPrint("✅ SDK initialized")
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
            debugPrint("❌ SDK not configured. Call configure(appKey:) first")
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

                debugPrint("📡 Scanning UUID: \(region.uuid)")
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
        debugPrint("🛑 Stopped all beacon scanning")
    }

    public func stopScanning(for uuidBeacon: String) {
        guard let locationManager = locationManager,
              let uuid = UUID(uuidString: uuidBeacon) else { return }

        let constraint = CLBeaconIdentityConstraint(uuid: uuid)

        if let region = beaconRegions.first(where: { $0.uuid == uuid }) {
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(satisfying: constraint)

            beaconRegions.removeAll { $0.uuid == uuid }

            debugPrint("🛑 Stopped scanning for UUID: \(uuidBeacon)")
        }
    }

    // MARK: - CLLocation Delegate
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            debugPrint("✅ Location authorized")
        } else {
            debugPrint("❌ Location denied")
        }
    }

    public func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {

        guard !beacons.isEmpty else { return }

        for beacon in beacons {
            debugPrint("📍 Beacon detected: \(beacon.uuid.uuidString) RSSI: \(beacon.rssi)")

            let uuidString = beacon.uuid.uuidString

            // Check if beacon exists in provided externalRegions
            let isAllowed = externalRegions.contains { $0.uuid.uppercased() == uuidString.uppercased() }

            guard isAllowed else {
                debugPrint("⛔️ Ignored beacon (not in list): \(uuidString)")
                continue
            }
            self.notifyUserWithCooldown(uuid: uuidString)
            NotificationCenter.default.post(
                name: NSNotification.Name("BeaconIpmagix_Detected"),
                object: nil,
                userInfo: [
                    "uuid": beacon.uuid.uuidString,
                    "major": beacon.major,
                    "minor": beacon.minor,
                    "rssi": beacon.rssi
                ]
            )
        }
    }

    // MARK: - Permission Request
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .criticalAlert]
        ) { granted, error in
            if granted {
                debugPrint("✅ Notification permission granted")
            } else if let error = error {
                debugPrint("❌ Permission error: \(error.localizedDescription)")
            } else {
                debugPrint("⚠️ Notification permission DENIED — user must enable in Settings")
            }
        }
    }

    // MARK: - Fixed Fire Notification
    private func fireLocalNotification(body: String) {
        // ✅ Step 4: Always check authorization status before firing
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized ||
                    settings.authorizationStatus == .provisional else {
                debugPrint("⚠️ Notifications not authorized: \(settings.authorizationStatus.rawValue)")
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
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        debugPrint("❌ Notification error: \(error.localizedDescription)")
                    } else {
                        debugPrint("📢 Notification fired successfully")
                    }
                }
            }
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
        guard let _ = k else {
            debugPrint("please set api key first!")
            return
        }

        let url = URL(string: EndpointsBeacons.userNotify(beaconID: uuid))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(BaseBeaconApi.apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("\(BaseBeaconApi.token)", forHTTPHeaderField: "Authorization")


        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(NotifyUserBeaconResponse.self, from: data)
                debugPrint("🔐 Validation: \(result.data)")
                if result.success {
                    self.fireLocalNotification(body: result.data)
                } else {
                    debugPrint("❌ API failed: \(result.message)")
                }
            } catch {
                debugPrint("❌ Decoding error:", error)
            }
        }.resume()
    }

    private func notifyUserWithCooldown(uuid: String) {
        let now = Date()

        if let lastNotified = notifiedUUIDs[uuid] {
            let elapsed = now.timeIntervalSince(lastNotified)
            guard elapsed >= cooldownInterval else {
                print("Cooldown active for \(uuid). \(cooldownInterval - elapsed)s remaining.")
                return
            }
            // Cooldown expired — remove the lock and allow the call
            notifiedUUIDs.removeValue(forKey: uuid)
        } else {
            // First time seeing this UUID — lock it and skip
            notifiedUUIDs[uuid] = now
            print("UUID \(uuid) caught for the first time. Blocked until cooldown expires.")
            // After 5 seconds, remove the lock so next call goes through
            DispatchQueue.main.asyncAfter(deadline: .now() + cooldownInterval) { [weak self] in
                self?.notifiedUUIDs.removeValue(forKey: uuid)
                print("Cooldown expired for \(uuid). Ready to notify.")
            }
            return
        }

        notifiedUUIDs[uuid] = now
        self.notifyUser(uuid: uuid)
    }

}
