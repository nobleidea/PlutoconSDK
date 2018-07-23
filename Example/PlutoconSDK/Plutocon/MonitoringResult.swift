//
//  MonitoringResult.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 1. 17..
//  Copyright © 2018년 KongTech. All rights reserved.
//

import Foundation

class MonitoringResult {
    internal var scannedPlutocons: [Plutocon] = []
    
    @discardableResult
    internal func updateSensor(plutocon: Plutocon, position: Int) -> Plutocon? {
        guard scannedPlutocons.count > position else { return nil }
        let p = scannedPlutocons[position]
        
        plutocon.updateInterval(oldLastSeenMillis: p.lastSeenMillis)
        scannedPlutocons[position] = plutocon
        
        return plutocon
    }
    
    internal func addSensor(plutocon: Plutocon) {
        guard !scannedPlutocons.contains(plutocon) else { return }
        
        scannedPlutocons.append(plutocon)
    }
    
    internal func index(of plutocon: Plutocon) -> Int? {
        return scannedPlutocons.index(of: plutocon)
    }
    
    internal func removeAll() {
        scannedPlutocons.removeAll()
    }
}
