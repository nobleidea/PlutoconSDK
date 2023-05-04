//
//  PlutoconManager.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 1. 17..
//  Copyright © 2018년 KongTech. All rights reserved.
//

import Foundation
import CoreBluetooth


@objc public enum PlutoconManagerState : Int {
    
    case unknown
    
    case resetting
    
    case unsupported
    
    case unauthorized
    
    case poweredOff
    
    case poweredOn
}

public protocol PlutoconManagerDelegate {
    func plutoconManagerDidUpdateState(_ state: PlutoconManagerState)
    
    func plutoconManager(_ manager: PlutoconManager, didDiscover plutocon: Plutocon, plutocons: [Plutocon])
}

typealias PlutoconScanCompletion = (Plutocon, [Plutocon]) -> Void
public class PlutoconManager: NSObject {
    
    private var centralManager: CBCentralManager?
    internal var delegate: PlutoconManagerDelegate?
    
    internal var monitoringResult = MonitoringResult()
    
    // MARK: - Completions
    private var scanCompletion: PlutoconScanCompletion?
    
    // MARK: - Options
    fileprivate var isMonitoring: Bool = false
    public var isScanning: Bool {
        return centralManager != nil && centralManager!.isScanning
    }
    
    fileprivate var plutoconConnection: PlutoconConnection?
    
    public init(delegate: PlutoconManagerDelegate) {
        super.init()
        
        self.delegate = delegate
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func startScan(isMonitoring: Bool = false) {
        self.isMonitoring = isMonitoring
        self.monitoringResult.removeAll()
        
        self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : isMonitoring])
    }
    
    public func stopScan() {
        self.centralManager?.stopScan()
    }
    
    public func connect(connectionDelegate: PlutoconConnectionDelegate, target: Plutocon) -> PlutoconConnection {
        self.plutoconConnection = PlutoconConnection(central: self.centralManager)
        self.plutoconConnection?.connect(delegate: connectionDelegate, plutocon: target)
        return self.plutoconConnection!
    }
    
    public func disconnect() {
        self.plutoconConnection?.disconnect()
    }
}

// MARK: - CBCentralManagerDelegate
extension PlutoconManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.delegate?.plutoconManagerDidUpdateState(PlutoconManagerState(rawValue: central.state.rawValue)!)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard (RSSI as! Int) < 0 else { return }
        guard let plutocon = Plutocon.createFromScanResult(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI) else { return }
        
        if let p = monitoringResult.index(of: plutocon) {
            if let plutocon = self.monitoringResult.updateSensor(plutocon: plutocon, position: p) {
                self.delegate?.plutoconManager(self, didDiscover: plutocon, plutocons: self.monitoringResult.scannedPlutocons)
            }
        } else {
            self.monitoringResult.addSensor(plutocon: plutocon)
            self.delegate?.plutoconManager(self, didDiscover: plutocon, plutocons: self.monitoringResult.scannedPlutocons)
        }
    }
}

extension PlutoconManager {
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        plutoconConnection?.connectStateChanged(state: PlutoconConnectState.didConnect)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        plutoconConnection?.connectStateChanged(state: PlutoconConnectState.didDisconnect(error: error))
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        plutoconConnection?.connectStateChanged(state: PlutoconConnectState.didFailToConnect(error: error))
    }
}
