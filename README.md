# PlutoconSDK

[Plutocon](https://kong-tech.com/kong-beacon/plutocon)SDK for iOS

[![Version](https://img.shields.io/cocoapods/v/PlutoconSDK.svg?style=flat)](https://cocoapods.org/pods/PlutoconSDK)
[![License](https://img.shields.io/cocoapods/l/PlutoconSDK.svg?style=flat)](https://cocoapods.org/pods/PlutoconSDK)
[![Platform](https://img.shields.io/cocoapods/p/PlutoconSDK.svg?style=flat)](https://cocoapods.org/pods/PlutoconSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Xcode >= 9.0

iOS Deployment Target >= 10.0

## Installation

PlutoconSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PlutoconSDK'
```

## Example Usages
### Quick start for monitoring plutocons
```swift
let plutoconManager = PlutoconManager(delegate: self)

extension ViewController: PlutoconManagerDelegate {
    
    func plutoconManagerDidUpdateState(_ state: PlutoconManagerState) {
        guard state == .poweredOn else {
            return
        }

        /* The isMonitoring variable set you whether you want to receive only one callback for one device (default: isMonitoring = false) */
        self.plutoconManager?.startScan(isMonitoring: true)
    }
    
    // Scan callback 
    func plutoconManager(_ manager: PlutoconManager, didDiscover plutocon: Plutocon, plutocons: [Plutocon]) {
        // do something
    }
}
```

### Quick start for connecting plutocon
```swift

let plutoconConnection = plutoconManager.connect(connectionDelegate: self, target: plutocon)

extension ViewController: PlutoconConnectionDelegate {
    // Connection successful
    func plutoconConnection(_ connection: PlutoconConnection, didConnect plutocon: Plutocon) {
    
    }

    // Connection failed
    func plutoconConnection(_ connection: PlutoconConnection, didFailToConnect plutocon: Plutocon, error: Error?) {

    }

    // Disconnect
    func plutoconConnection(_ connection: PlutoconConnection, didDisconnectPeripheral plutocon: Plutocon, error: Error?) {
    
    }
}

// Read plutocon property
plutoconConnection.getBatteryVoltage()
plutoconConnection.getBroadcastingPower()
plutoconConnection.getAdvertisingInterval()

plutoconConnection.getUuid()
plutoconConnection.getLatitude()
plutoconConnection.getLongitude()

plutoconConnection.getSoftwareVersion()
plutoconConnection.getHardwareVersion()
plutoconConnection.getManufactureName()
plutoconConnection.getModelNumber()

// Disconnect from plutocon
plutoconConnection.disconnect()
```

### Quick start for edit plutocon property
````swift
plutoconConnection.editor()
    .setUUID(uuid)
    .setProperty(uuid: uuid, int: value)
    .setProperty(uuid: uuid, string: value)
    .setOperationCompletion(completion: { (_, isLast) in
        // do something
    })
    .commit()
````

## Author

dhhyuk, kongkdh@kong-tech.com

## License

PlutoconSDK is available under the MIT license. See the LICENSE file for more info.
