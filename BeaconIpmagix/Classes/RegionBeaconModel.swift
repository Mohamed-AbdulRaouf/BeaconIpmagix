//
//  RegionBeaconModel.swift
//  Runner
//
//  Created by Raouf on 30/07/2025.
//
import CoreLocation
import Foundation

public struct RegionBeaconModel: Codable {
    var uuid: String = ""
    let beaconMac: String
    let orgID: String
    let groupID: String
    let categoryID: String
    let name: String
    let placeID: String
    let notificationID: String
    let major: String?
    let minor: String?
    let insertDate: String?
    
   public init(uuid: String = "", beaconMac: String, orgID: String, groupID: String, categoryID: String, name: String, placeID: String, notificationID: String, major: String? = nil, minor: String? = nil, insertDate: String? = nil) {
        self.uuid = uuid
        self.beaconMac = beaconMac
        self.orgID = orgID
        self.groupID = groupID
        self.categoryID = categoryID
        self.name = name
        self.placeID = placeID
        self.notificationID = notificationID
        self.major = major
        self.minor = minor
        self.insertDate = insertDate
    }
    // CodingKeys to map JSON keys to struct properties (if needed)
    public enum CodingKeys: String, CodingKey {
        case beaconMac
        case orgID
        case groupID
        case categoryID
        case name
        case placeID
        case notificationID
        case major
        case minor
        case insertDate
    }
}

// Struct to store beacon details
struct DetectedBeacon: Equatable {
    let uuid: UUID
    let major: CLBeaconMajorValue
    let minor: CLBeaconMinorValue
    let proximity: String
    let rssi: Int
    
    // Equatable to compare beacons by UUID, major, and minor
    static func ==(lhs: DetectedBeacon, rhs: DetectedBeacon) -> Bool {
        return lhs.uuid == rhs.uuid && lhs.major == rhs.major && lhs.minor == rhs.minor
    }
}
