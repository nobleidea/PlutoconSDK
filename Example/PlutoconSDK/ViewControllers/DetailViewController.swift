//
//  DetailViewController.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 7. 20..
//  Copyright © 2018년 KongTech. All rights reserved.
//

import UIKit
import CoreBluetooth

class DetailViewController: UIViewController {

    @IBOutlet weak var viewDeviceName: DetailDataView!
    @IBOutlet weak var viewMajor: DetailDataView!
    @IBOutlet weak var viewMinor: DetailDataView!
    @IBOutlet weak var viewUUID: DetailDataVerticalView!
    
    public var plutoconConnection: PlutoconConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.plutoconConnection?.targetPlutocon?.name ?? "Plutocon"
        
        self.plutoconConnection?.delegate = self
        
        /**
         * 현재 Plutocon의 정보 데이터는 PlutoconConnection의 getMajor(), getDeviceName() 등을 통해서 가져올 수 있음
         *
         * PlutoconEditor는 Plutocon의 정보를 변경하는데 사용되고, 이는 PlutoconConnection의 editor()함수를 통해서 생성할 수 있으며
         * setProperty() 함수를 통해 변경할 정보(uuid), 데이터(int or string)의 형태로 Builder패턴처럼 사용가능 하고,
         * setOperationCompletion을 통해 데이터가 변경될때 콜백을 등록하고, commit()을 통해 변경을 실행합니다.
         *
         * PlutoconReader는 Plutocon의 정보를 갱신하는데 사용되고 이는 PlutoconConnection의 readaer()함수를 통해서 생성할 수 있으며
         * getProperty() 함수를 통해서 갱신할 정보(uuid)의 형태로 Builder패턴처럼 사용가능하고,
         * 마찬가지로 setOperationCompletion를 통해 콜백을 등록하고, commit()을 통해 작업을 실행시킴,
         * 이후 PlutoconConnection으로 정보를 조회시, 갱신된 데이터로 사용가능
         */
        if let deviceName = self.plutoconConnection?.getDeviceName() {
            self.viewDeviceName.value = deviceName
            self.viewDeviceName.completion = {
                let alert = self.makeEditAlert(title: self.viewDeviceName.title, value: self.viewDeviceName.value, completion: { text in
                    self.plutoconConnection?.editor()
                        .setProperty(uuid: PlutoconUUID.DEVICE_NAME_CHARACTERISTIC, string: text)
                        .setOperationCompletion(completion: { (_, isLast) in
                            if isLast {
                                self.viewDeviceName.value = self.plutoconConnection?.getDeviceName() ?? ""
                            }
                        })
                        .commit()
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        if let major = self.plutoconConnection?.getMajor() {
            self.viewMajor.value = "\(major)"
            self.viewMajor.completion = {
                let alert = self.makeEditAlert(title: self.viewMajor.title, value: self.viewMajor.value, completion: { text in
                    self.plutoconConnection?.editor()
                        .setProperty(uuid: PlutoconUUID.MAJOR_CHARACTERISTIC, int: Int(text) ?? 0)
                        .setOperationCompletion(completion: { (_, isLast) in
                            if isLast {
                                self.viewMajor.value = "\(self.plutoconConnection?.getMajor() ?? 0)"
                            }
                        })
                        .commit()
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        if let minor = self.plutoconConnection?.getMinor() {
            self.viewMinor.value = "\(minor)"
            self.viewMinor.completion = {
                let alert = self.makeEditAlert(title: self.viewMinor.title, value: self.viewMinor.value, completion: { text in
                    self.plutoconConnection?.editor()
                        .setProperty(uuid: PlutoconUUID.MINOR_CHARACTERISTIC, int: Int(text) ?? 0)
                        .setOperationCompletion(completion: { (_, isLast) in
                            if isLast {
                                self.viewMinor.value = "\(self.plutoconConnection?.getMinor() ?? 0)"
                            }
                        })
                        .commit()
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        if let uuid = self.plutoconConnection?.getUuid() {
            self.viewUUID.value = uuid.uuidString
            self.viewUUID.completion = {
                let alert = self.makeEditAlert(title: self.viewUUID.title, value: self.viewUUID.value, completion: { (text) in
                    guard let uuid = UUID(uuidString: text) else {
                        return
                    }
                    let cbuuid = CBUUID(nsuuid: uuid)
                    
                    self.plutoconConnection?.editor()
                        .setUUID(uuid: cbuuid)
                        .setOperationCompletion(completion: { (_, isLast) in
                            if isLast {
                                self.viewUUID.value = self.plutoconConnection?.getUuid()?.uuidString ?? ""
                            }
                        })
                        .commit()
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParentViewController {
            self.plutoconConnection?.disconnect()
        }
    }
    
    fileprivate func makeEditAlert(title: String, value: String, completion: @escaping ((String)->Void)) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) { (action) in
            if (alert.textFields?.count ?? 0) > 0 {
                let text = alert.textFields?.first?.text ?? ""
                if text != "" {
                    completion(text)
                }
            }
        }
        let cancel = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(action)
        
        alert.addTextField { (textField) in
            textField.text = value
        }
        
        return alert
    }
}

// MARK: - PlutoconConnectionDelegate
extension DetailViewController: PlutoconConnectionDelegate {
    func plutoconConnection(_ connection: PlutoconConnection, didConnect plutocon: Plutocon) {
        
    }
    
    func plutoconConnection(_ connection: PlutoconConnection, didFailToConnect plutocon: Plutocon, error: Error?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func plutoconConnection(_ connection: PlutoconConnection, didDisconnectPeripheral plutocon: Plutocon, error: Error?) {
        self.navigationController?.popViewController(animated: true)
        print("disconnect")
    }
}
