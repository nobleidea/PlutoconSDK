//
//  PlutoconUUID.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 1. 17..
//  Copyright © 2018년 KongTech. All rights reserved.
//

import Foundation
import CoreBluetooth

public class PlutoconUUID {
    public static let SERVICE_DATA_UUID = CBUUID(string: "0000180a-0000-1000-8000-00805f9b34fb")
    
    public static let DEFAULT_UUID = CBUUID(string: "1f4ae6a0-0037-4016-8201-271085550001")
    
    public static let MANUFACTURE_NAME_CHARACTERISTIC = CBUUID(string: "1f4ae6a0-0037-4020-4101-271071580001")
    public static let MODEL_NUMBER_CHARACTERISTIC = CBUUID(string: "9fd41002-e46f-7c9a-57b1-2da365e18fa1")
    public static let SOFTWARE_VERSION_CHARACTERISTIC = CBUUID(string: "9fd41003-e46f-7c9a-57b1-2da365e18fa1")
    public static let HARDWARE_VERSION_CHARACTERISTIC = CBUUID(string: "9fd41004-e46f-7c9a-57b1-2da365e18fa1")
    
    public static let UUID_CHARACTERISTIC = CBUUID(string: "9fd42001-e46f-7c9a-57b1-2da365e18fa1")
    public static let MAJOR_CHARACTERISTIC = CBUUID(string: "9fd42002-e46f-7c9a-57b1-2da365e18fa1")
    public static let MINOR_CHARACTERISTIC = CBUUID(string: "9fd42003-e46f-7c9a-57b1-2da365e18fa1")
    public static let TX_LEVEL_CHARACTERISTIC = CBUUID(string: "9fd42004-e46f-7c9a-57b1-2da365e18fa1")
    public static let ADV_INTERVAL_CHARACTERISTIC = CBUUID(string: "9fd42005-e46f-7c9a-57b1-2da365e18fa1")
    public static let DEVICE_NAME_CHARACTERISTIC = CBUUID(string: "9fd42006-e46f-7c9a-57b1-2da365e18fa1")
    
    public static let BATTERY_CHARACTERISTIC = CBUUID(string: "9fd43001-e46f-7c9a-57b1-2da365e18fa1")
    
    public static let SENSOR_CHARACTERISTIC = CBUUID(string: "9fd45002-e46f-7c9a-57b1-2da365e18fa1")
}
