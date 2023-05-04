//
//  Extensions.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 7. 20..
//  Copyright © 2018년 KongTech. All rights reserved.
//

import Foundation

extension String {
    func subString(start: Int, end: Int) -> String {
        let sIndex = self.index(startIndex, offsetBy: start)
        let eIndex = self.index(startIndex, offsetBy: end)
        
        return String(self[sIndex..<eIndex])
    }
}
