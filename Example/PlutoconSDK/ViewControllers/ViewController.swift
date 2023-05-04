//
//  ViewController.swift
//  PlutoconSDK
//
//  Created by 김동혁 on 2018. 1. 17..
//  Copyright © 2018년 KongTech. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    var plutoconManager: PlutoconManager?
    var plutoconConnection: PlutoconConnection?
    var scannedPlutocons: [Plutocon] = []
    
    fileprivate var connectingIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: PlutoconCell.CellId, bundle: nil), forCellReuseIdentifier: PlutoconCell.CellId)
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        
        
        plutoconManager = PlutoconManager(delegate: self)
    }
    
    @objc func refreshControlValueChanged() {
        self.scannedPlutocons.removeAll()
        self.connectingIndex = nil
        self.tableView.reloadData()
        
        if self.plutoconManager?.isScanning == true {
            self.plutoconManager?.stopScan()
        }
        self.plutoconManager?.startScan()
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetailSegue", let detailVC = segue.destination as? DetailViewController {
            detailVC.plutoconConnection = self.plutoconConnection
        }
    }
}

// MARK: - PlutoconManagerDelegate
extension ViewController: PlutoconManagerDelegate {
    
    /**
     * 블루투스 상태(On인지 Off인지 지원이 안되는지)가 변경될 때 실행되는 함수
     */
    func plutoconManagerDidUpdateState(_ state: PlutoconManagerState) {
        /* 블루투스 상태가 PoweredOn이 아니라면 return시키고, PoweredOn일 때 스캔 시작 */
        guard state == .poweredOn else {
            return
        }
        print(#function)
        
        /* isMonitoring 옵션으로 하나의 기기에 대해서 콜백을 한번만 받을 건지 계속 스캔되게 할건지 설정 */
        self.plutoconManager?.startScan(isMonitoring: true)
    }
    
    /**
     * Plutocon이 스캔 될때마다 실행되는 함수
     * 스캔된 plutocon과 지금까지 스캔된 plutocons
     */
    func plutoconManager(_ manager: PlutoconManager, didDiscover plutocon: Plutocon, plutocons: [Plutocon]) {
        self.scannedPlutocons = plutocons
        self.tableView.reloadData()
    }
}

// MARK: - PlutoconConnectionDelegate
extension ViewController: PlutoconConnectionDelegate {
    
    /**
     * Plutocon에 연결 시도하고, 연결에 대한 결과에 따라서 실행되는 함수
     */
    
    /* 연결에 성공했을 때 */
    func plutoconConnection(_ connection: PlutoconConnection, didConnect plutocon: Plutocon) {
        print(#function)
        let tempIndex = self.connectingIndex
        self.connectingIndex = nil
        
        if let tempIndex = tempIndex {
            self.tableView.reloadRows(at: [tempIndex], with: UITableViewRowAnimation.none)
        }
        performSegue(withIdentifier: "goDetailSegue", sender: nil)
    }
    
    /* 연결에 실패했을 때 */
    func plutoconConnection(_ connection: PlutoconConnection, didFailToConnect plutocon: Plutocon, error: Error?) {
        print("didFailToConnect error : \(error?.localizedDescription ?? "")")
    }
    
    /* 연결이 해제되었을 때 */
    func plutoconConnection(_ connection: PlutoconConnection, didDisconnectPeripheral plutocon: Plutocon, error: Error?) {
        print("didDisconnect error : \(error?.localizedDescription ?? "")")
    }
}

// MARK: - UITableViewDelegate, Datasource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.scannedPlutocons.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlutoconCell.CellId, for: indexPath) as! PlutoconCell
        let plutocon = self.scannedPlutocons[indexPath.row]
        
        cell.labelName.text = plutocon.name
        cell.labelMac.text = plutocon.macAddress
        
        if let connectingIndex = self.connectingIndex, connectingIndex == indexPath {
            cell.viewIndicator.isHidden = false
            cell.viewIndicator.startAnimating()
        } else {
            cell.viewIndicator.isHidden = true
            cell.viewIndicator.stopAnimating()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        connectingIndex = indexPath
        
        self.plutoconManager?.stopScan()
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        
        /* Cell이 선택되면 해당 Plutocon에 연결을 시도하고 PlutoconConnection을 통해서 Plutocon의 데이터를 변경, 조회 함 */
        self.plutoconConnection = self.plutoconManager?.connect(connectionDelegate: self, target: self.scannedPlutocons[indexPath.row])
    }
}
