//
//  PlutoconReader.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 1. 18..
//

import Foundation
import CoreBluetooth

internal protocol PlutoconReaderDelegate {
    func plutoconReader(readCharacteristic uuid: CBUUID)
}


public typealias OperationCompletion = ((CBCharacteristic, Bool) -> Void)

public class PlutoconReader: NSObject {
    
    fileprivate var operationList: [CBUUID] = []
    
    fileprivate var operationCompletion: OperationCompletion?
    
    fileprivate var delegate: PlutoconReaderDelegate?
    
    internal init(delegate: PlutoconReaderDelegate?) {
        self.delegate = delegate
    }
    
    public func setOperationCompletion(completion: @escaping OperationCompletion) -> PlutoconReader {
        self.operationCompletion = completion
        return self
    }
    
    public func getProperty(uuid: CBUUID) -> PlutoconReader {
        //guard let uuid = characteristics[uuid] else { return self }
        operationList.append(uuid)
        return self
    }
    
    public func commit() {
        _ = execute()
    }
    
    public func execute() -> Bool {
        if let uuid = nextOperation() {
            delegate?.plutoconReader(readCharacteristic: uuid)
            return true
        }
        return false
    }
    
    // MARK: - Operation
    public func operationComplete(characteristic: CBCharacteristic, isLast: Bool) {
        self.operationCompletion?(characteristic, isLast)
    }
    
    public func nextOperation() -> CBUUID? {
        if operationList.count > 0 {
            let uuid = operationList.remove(at: 0)
            return uuid
        }
        return nil
    }
}
