//
//  PlutoconEditor.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 1. 18..
//

import Foundation
import CoreBluetooth

internal protocol PlutoconEditorDelegate {
    func plutoconEditor(writeCharacteristic uuid: CBUUID, data: Data)
    func plutoconEditorGetUuid() -> String
}

public class PlutoconEditor: NSObject {
    
    fileprivate var operationList: [(CBUUID, Data)] = []
    
    fileprivate var operationCompletion: OperationCompletion?
    
    fileprivate var delegate: PlutoconEditorDelegate?
    
    internal init(delegate: PlutoconEditorDelegate?) {
        self.delegate = delegate
    }
    
    public func setOperationCompletion(completion: @escaping OperationCompletion) -> PlutoconEditor {
        self.operationCompletion = completion
        return self
    }
    
    fileprivate func getUuidFromPlace(baseUuid: String, latitude: Double, isLatitudeNegative: Bool, longitude: Double, isLongitudeNegative: Bool) -> String {
        var uuid: String = baseUuid;
        let slatitude: String = (isLatitudeNegative ? "1" : "0") + String(format: "%03d%06d", Int(latitude), Int(((latitude - Double(Int(latitude))) * 1000000)));
        let slongitude: String = (isLongitudeNegative ? "1" : "0") + String(format: "%03d%06d", Int(longitude), Int(((longitude - Double(Int(longitude))) * 1000000)));
        
        uuid = uuid.subString(start:0, end: 9) + "-" + slatitude.subString(start: 0, end: 4) + "-" + uuid.subString(start: 12, end: uuid.count)
        uuid = uuid.subString(start: 0, end: 14) + slatitude.subString(start: 4, end: 8) + "-" + uuid.subString(start: 18, end: uuid.count)
        uuid = uuid.subString(start: 0, end: 19) + slatitude.subString(start: 8, end: 10) + uuid.subString(start: 21, end: uuid.count)
        
        uuid = uuid.subString(start: 0, end: 21) + slongitude.subString(start: 0, end: 2) + "-" + uuid.subString(start: 23, end: uuid.count)
        uuid = uuid.subString(start: 0, end: 24) + slongitude.subString(start: 2, end: 4) + uuid.subString(start: 26, end: uuid.count)
        uuid = uuid.subString(start: 0, end: 26) + slongitude.subString(start: 4, end: 10) + uuid.subString(start: 36, end: uuid.count)
        
        return uuid;
    }
    
    public func setGeofence(latitude: Double, longitude: Double) -> PlutoconEditor {
        let uuidFromPlace = self.getUuidFromPlace(baseUuid: delegate?.plutoconEditorGetUuid() ?? "", latitude: latitude, isLatitudeNegative: latitude < 0, longitude: longitude, isLongitudeNegative: longitude < 0)
        
        changeUUID(uuid: CBUUID(string: uuidFromPlace))
        return self
    }
    
    public func setUUID(uuid: CBUUID) -> PlutoconEditor {
        changeUUID(uuid: uuid)
        return self
    }
    
    public func setUUID(uuidString: String) -> PlutoconEditor {
        changeUUID(uuid: CBUUID(string: uuidString))
        return self
    }
    
    fileprivate func changeUUID(uuid: CBUUID) {
        operationList.append((PlutoconUUID.UUID_CHARACTERISTIC, uuid.data))
    }
    
    public func setProperty(uuid: CBUUID, int value: Int) -> PlutoconEditor {
        var d = [UInt8](repeating: 0, count: 2)
        let v = Int16(value)
        d[0] = UInt8(bitPattern: Int8(v >> 8))
        d[1] = UInt8(v & 0xFF)
        
        self.operationList.append((uuid,Data(bytes: d)))
        return self
    }
    
    public func setProperty(uuid: CBUUID, string value: String) -> PlutoconEditor {
        self.operationList.append((uuid, Data(bytes: [UInt8](value.utf8))))
        return self
    }
    
    public func commit() {
        _ = execute()
    }
    
    public func execute() -> Bool {
        if let data = nextOperation() {
            delegate?.plutoconEditor(writeCharacteristic: data.0, data: data.1)
            return true
        }
        return false
    }
    
    // MARK: - Operation
    public func operationComplete(characteristic: CBCharacteristic, isLast: Bool) {
        self.operationCompletion?(characteristic, isLast)
    }
    
    public func nextOperation() -> (CBUUID, Data)? {
        if operationList.count > 0 {
            let data = operationList.remove(at: 0)
            return data
        }
        return nil
    }
}
