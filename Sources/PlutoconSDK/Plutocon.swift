//
//  Plutocon.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 1. 17..
//  Copyright © 2018년 KongTech. All rights reserved.
//

import Foundation
import CoreBluetooth

public class Plutocon: Equatable {
    internal static let SERVICE_DATA_UUID = CBUUID(string: "0000180a-0000-1000-8000-00805f9b34fb")
    
    public var peripheral: CBPeripheral?
    
    public var name: String
    public var macAddress: String
    
    public var uuid: CBUUID?
    
    public var major: Int
    public var minor: Int
    
    public var rssi: Int
    public var interval: Int
    public var lastSeenMillis = TimeInterval()
    
    public var battery: Int
    
    public var isMonitoring: Bool = false
    public var isCertification: Bool = false
    
    public var latitude: Double {
        get {
            guard let uuidStr = uuid?.uuidString else { return 0 }
            
            if let latitudeHigh = Double(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 9)..<uuidStr.index(uuidStr.startIndex, offsetBy: 13)])),
                let latitudeLow = Double("\(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 14)..<uuidStr.index(uuidStr.startIndex, offsetBy: 18)]))\(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 19)..<uuidStr.index(uuidStr.startIndex, offsetBy: 21)]))") {
                return (latitudeHigh * 1000000 + latitudeLow)/1000000 * (uuid!.uuidString[String.Index(encodedOffset: 9)] == "1" ? -1 : 1)
            }
            return 0
        }
    }
    public var longitude: Double {
        get {
            guard let uuidStr = uuid?.uuidString else { return 0 }
            
            if let longitudeHigh = Double("\(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 21)..<uuidStr.index(uuidStr.startIndex, offsetBy: 23)]))\(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 24)..<uuidStr.index(uuidStr.startIndex, offsetBy: 26)]))"),
                let longitudeLow = Double(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 26)..<uuidStr.index(uuidStr.startIndex, offsetBy: 32)])) {
                return (longitudeHigh * 1000000 + longitudeLow)/1000000 * (uuid!.uuidString[String.Index(encodedOffset: 21)] == "1" ? -1 : 1)
            }
            return 0
        }
    }
    
    public init(name: String, macAddress: String) {
        self.name = name
        self.macAddress = macAddress.uppercased()
        self.rssi = 0
        self.lastSeenMillis = 0
        self.interval = 0
        self.isMonitoring = false
        self.major = 0
        self.minor = 0
        self.battery = 0
    }
    
    fileprivate init(peripheral: CBPeripheral, name: String, rssi: NSNumber, battery: Int, manufacturerData: [UInt8], serviceData: [UInt8], isCertification: Bool) {
        self.peripheral = peripheral
        
        self.name = name
        var macString = ""
        for num in 2..<8
        {
            let b = serviceData[num]
            
            macString.append(String(format: "%02X", b))
            
            if num != 7
            {
                macString.append(":")
            }
        }
        self.macAddress = macString
        
        let uuidArr = manufacturerData[4..<20]
        self.uuid = CBUUID(data: Data(bytes: uuidArr))
        
        self.major = Int(UInt16(manufacturerData[20] & 0xff) << 8 | UInt16(manufacturerData[21] & 0xff))
        self.minor = Int(UInt16(manufacturerData[22] & 0xff) << 8 | UInt16(manufacturerData[23] & 0xff))
        
        self.rssi = rssi as! Int
        self.interval = 0
        self.lastSeenMillis = Date().timeIntervalSince1970
        
        self.battery = battery
        
        self.isCertification = isCertification
        self.isMonitoring = isCertification
    }
    
    public func setiBeacon(uuid: CBUUID, major: Int, minor: Int) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
    }
    
    public func updateInterval(oldLastSeenMillis: TimeInterval) {
        let temp = Int((self.lastSeenMillis - oldLastSeenMillis) * 1000)
        self.interval = temp
    }
    
    public func disapeared() {
        isMonitoring = false
    }
    
    internal static func createFromScanResult(peripheral: CBPeripheral, advertisementData: [String:Any], rssi: NSNumber) -> Plutocon? {
        guard let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
            let advManufacturer = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
            let advService = (advertisementData[CBAdvertisementDataServiceDataKey] as? NSDictionary)?.allValues[0] as? Data
            else { return nil }
        
        var serviceDataArr = [UInt8](repeating: 0, count: 8)
//        advService.copyBytes(to: &serviceDataArr, count: serviceDataArr.count)
        
        var manufacturerDataArr = [UInt8](repeating: 0, count: advManufacturer.count)
        advManufacturer.copyBytes(to: &manufacturerDataArr, count: manufacturerDataArr.count)
        
        if serviceDataArr.count < 1, serviceDataArr[0] != 0x01 { return nil }
        
//        let battery = Int(UInt16(serviceDataArr[8]) << 8 | UInt16(serviceDataArr[9] & 0xff))
        
        return Plutocon(peripheral: peripheral, name: name, rssi: rssi, battery: 10, manufacturerData: manufacturerDataArr, serviceData: serviceDataArr, isCertification: true)
    }
    
    public static func ==(lhs: Plutocon, rhs: Plutocon) -> Bool {
        return lhs.macAddress == rhs.macAddress
    }
}
