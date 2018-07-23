//
//  PlutoconConnection.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 1. 17..
//  Copyright © 2018년 KongTech. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum PlutoconConnectState {
    case didConnect
    case didDisconnect(error: Error?)
    case didFailToConnect(error: Error?)
}

public protocol PlutoconConnectionDelegate {
    func plutoconConnection(_ connection: PlutoconConnection, didConnect plutocon: Plutocon)
    func plutoconConnection(_ connection: PlutoconConnection, didFailToConnect plutocon: Plutocon, error: Error?)
    func plutoconConnection(_ connection: PlutoconConnection, didDisconnectPeripheral plutocon: Plutocon, error: Error?)
}

public class PlutoconConnection: NSObject {
    public typealias ConnectCompletion = ((PlutoconConnectState) -> Void)
    public typealias RemoteRssiCompletion = ((Int)->Void)
    
    weak var centralManager: CBCentralManager?
    
    public var targetPlutocon: Plutocon?
    fileprivate var characteristics: [CBUUID: CBCharacteristic] = [:]
    
    public var delegate: PlutoconConnectionDelegate?
    fileprivate var remoteRssiCompletion: RemoteRssiCompletion?
    
    fileprivate var characteristicCnt = 0
    fileprivate var characteristicCntTemp = 0
    
    public var isConnected: Bool = false
    
    fileprivate var plutoconReader: PlutoconReader?
    fileprivate var plutoconEditor: PlutoconEditor?
    
    fileprivate var readRssiTimer: Timer?
    
    public init(central centralManager: CBCentralManager?) {
        super.init()
        
        self.centralManager = centralManager
    }
    
    deinit {
        targetPlutocon?.peripheral?.delegate = nil
        targetPlutocon = nil
    }
    
    public func connect(delegate: PlutoconConnectionDelegate, plutocon: Plutocon) {
        self.characteristics.removeAll()
        self.targetPlutocon = plutocon
        self.delegate = delegate
        
        self.characteristicCnt = 0
        self.characteristicCntTemp = 0
        self.centralManager?.connect(targetPlutocon!.peripheral!, options: nil)
    }
    
    public func disconnect() {
        self.readRssiTimer?.invalidate()
        
        guard let peripheral = targetPlutocon?.peripheral else { return }
        centralManager?.cancelPeripheralConnection(peripheral)
    }
    
    internal func connectStateChanged(state: PlutoconConnectState) {
        switch state {
        case .didConnect:
            targetPlutocon?.peripheral?.delegate = self
            targetPlutocon?.peripheral?.discoverServices(nil)
        case .didDisconnect(let error):
            isConnected = false
            characteristics.removeAll()
            
            if let plutocon = self.targetPlutocon {
                self.delegate?.plutoconConnection(self, didDisconnectPeripheral: plutocon, error: error)
            }
            targetPlutocon = nil
        case .didFailToConnect(let error):
            isConnected = false
            characteristics.removeAll()
            
            if let plutocon = self.targetPlutocon {
                self.delegate?.plutoconConnection(self, didFailToConnect: plutocon, error: error)
            }
            targetPlutocon = nil
        }
    }
    
    public func reader() -> PlutoconReader {
        plutoconReader = PlutoconReader(delegate: self)
        return plutoconReader!
    }
    
    public func editor() -> PlutoconEditor {
        plutoconEditor = PlutoconEditor(delegate: self)
        return plutoconEditor!
    }
}

// MARK: - CBPeripheralDelegate
extension PlutoconConnection: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        characteristicCnt += characteristics.count
        
        for characteristic in characteristics {
            peripheral.readValue(for: characteristic)
            self.characteristics[characteristic.uuid] = characteristic
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if !self.isConnected {
            self.characteristicCntTemp += 1
            if self.characteristicCnt == self.characteristicCntTemp {
                self.isConnected = true
                
                if let plutocon = self.targetPlutocon {
                    self.delegate?.plutoconConnection(self, didConnect: plutocon)
                }
            }
        }
        characteristics[characteristic.uuid] = characteristic
        
        plutoconReader?.operationComplete(characteristic: characteristic, isLast: !(plutoconReader?.execute() ?? false))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        characteristics[characteristic.uuid] = characteristic
        
        plutoconEditor?.operationComplete(characteristic: characteristic, isLast: !(plutoconEditor?.execute() ?? false))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        self.remoteRssiCompletion?(RSSI as! Int)
    }
}

// MARK: - Get plutocon datas
extension PlutoconConnection {
    
    public func getRemoteRssi(completion: RemoteRssiCompletion?) {
        self.remoteRssiCompletion = completion
        targetPlutocon?.peripheral?.readRSSI()
    }
    
    public func startMonitoringRssi(interval: TimeInterval, completion: RemoteRssiCompletion?) {
        self.remoteRssiCompletion = completion
        
        readRssiTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(readRSSI), userInfo: nil, repeats: true)
    }
    
    public func stopMonitoringRssi() {
        readRssiTimer?.invalidate()
    }
    
    @objc func readRSSI() {
        targetPlutocon?.peripheral?.readRSSI()
    }
    
    public func getAdvertisingInterval() -> Int? {
        guard let value = characteristics[PlutoconUUID.ADV_INTERVAL_CHARACTERISTIC]?.value else { return nil }
        var bytes: [UInt8] = [UInt8](repeating: 0, count: value.count)
        value.copyBytes(to: &bytes, count: bytes.count)
        
        return Int(CShort(bitPattern: UInt16(bytes[0]) << 8 | UInt16(bytes[1]) & 0xff))
    }
    
    public func getBroadcastingPower() -> Int? {
        guard let value = characteristics[PlutoconUUID.TX_LEVEL_CHARACTERISTIC]?.value else { return nil }
        var bytes: [UInt8] = [UInt8](repeating: 0, count: value.count)
        value.copyBytes(to: &bytes, count: bytes.count)
        
        return Int(CShort(bitPattern: UInt16(bytes[0]) << 8 | UInt16(bytes[1]) & 0xff))
    }
    
    public func getBatteryVoltage() -> Int? {
        guard let value = characteristics[PlutoconUUID.BATTERY_CHARACTERISTIC]?.value else { return nil }
        var bytes: [UInt8] = [UInt8](repeating: 0, count: value.count)
        value.copyBytes(to: &bytes, count: bytes.count)
        
        return (Int(bytes[0]) << 8) | Int(bytes[1] & 0xff)
    }
    
    public func getMajor() -> Int? {
        guard let value = characteristics[PlutoconUUID.MAJOR_CHARACTERISTIC]?.value else { return nil }
        var bytes: [UInt8] = [UInt8](repeating: 0, count: value.count)
        value.copyBytes(to: &bytes, count: bytes.count)
        
        return (Int(bytes[0]) << 8) | Int(bytes[1] & 0xff)
    }
    
    public func getMinor() -> Int? {
        guard let value = characteristics[PlutoconUUID.MINOR_CHARACTERISTIC]?.value else { return nil }
        var bytes: [UInt8] = [UInt8](repeating: 0, count: value.count)
        value.copyBytes(to: &bytes, count: bytes.count)
        
        return (Int(bytes[0]) << 8) | Int(bytes[1] & 0xff)
    }
    
    public func getSoftwareVersion() -> String? {
        guard let value = characteristics[PlutoconUUID.SOFTWARE_VERSION_CHARACTERISTIC]?.value else { return nil }
        return String(data: value, encoding: .utf8)
    }
    
    public func getHardwareVersion() -> String? {
        guard let value = characteristics[PlutoconUUID.HARDWARE_VERSION_CHARACTERISTIC]?.value else { return nil }
        return String(data: value, encoding: .utf8)
    }
    
    public func getModelNumber() -> String? {
        guard let value = characteristics[PlutoconUUID.MODEL_NUMBER_CHARACTERISTIC]?.value else { return nil }
        return String(data: value, encoding: .utf8)
    }
    
    public func getManufactureName() -> String? {
        guard let value = characteristics[PlutoconUUID.MANUFACTURE_NAME_CHARACTERISTIC]?.value else { return nil }
        return String(data: value, encoding: .utf8)
    }
    
    public func getUuid() -> CBUUID? {
        guard let value = characteristics[PlutoconUUID.UUID_CHARACTERISTIC]?.value else { return nil }
        return CBUUID(data: value)
    }
    
    public func getDeviceName() -> String? {
        guard let value = characteristics[PlutoconUUID.DEVICE_NAME_CHARACTERISTIC]?.value else { return nil }
        return String(data: value.filter { $0 != 0x00 }, encoding: .utf8)
    }
    
    public func getLatitude() -> Double {
        let uuid = getUuid()
        guard let uuidStr = uuid?.uuidString else { return 0 }
        
        if let latitudeHigh = Double(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 9)..<uuidStr.index(uuidStr.startIndex, offsetBy: 13)])),
            let latitudeLow = Double("\(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 14)..<uuidStr.index(uuidStr.startIndex, offsetBy: 18)]))\(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 19)..<uuidStr.index(uuidStr.startIndex, offsetBy: 21)]))") {
            return (latitudeHigh * 1000000 + latitudeLow) / 1000000
        }
        return 0
    }
    
    public func getLongitude() -> Double {
        let uuid = getUuid()
        guard let uuidStr = uuid?.uuidString else { return 0 }
        
        if let longitudeHigh = Double("\(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 21)..<uuidStr.index(uuidStr.startIndex, offsetBy: 23)]))\(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 24)..<uuidStr.index(uuidStr.startIndex, offsetBy: 26)]))"),
            let longitudeLow = Double(String(uuidStr[uuidStr.index(uuidStr.startIndex, offsetBy: 26)..<uuidStr.index(uuidStr.startIndex, offsetBy: 32)])) {
            return (longitudeHigh * 1000000 + longitudeLow) / 1000000
        }
        return 0
    }
}

// MARK: - PlutoconReaderDelegate
extension PlutoconConnection: PlutoconReaderDelegate {
    public func plutoconReader(readCharacteristic uuid: CBUUID) {
        guard let characteristic = characteristics[uuid] else { return }
        self.targetPlutocon?.peripheral?.readValue(for: characteristic)
    }
}

extension PlutoconConnection: PlutoconEditorDelegate {
    
    public func plutoconEditor(writeCharacteristic uuid: CBUUID, data: Data) {
        guard let characteristic = characteristics[uuid] else { return }
        characteristic.setValue(data, forKeyPath: "value")
        self.targetPlutocon?.peripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func plutoconEditorGetUuid() -> String {
        return targetPlutocon?.uuid?.uuidString ?? ""
    }
}
