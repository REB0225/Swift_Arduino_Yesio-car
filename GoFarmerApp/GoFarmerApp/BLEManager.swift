//
//  BLEManager.swift
//  Esp32LedSwitcher
//
//  Created by 徐來慶 on 2025/2/17.
//

import CoreBluetooth

public class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var statusText = "Scanning..."  // Use @Published for UI updates
    @Published var gotResponseText = "no"
    @Published var foundPeripherals: [CBPeripheral] = [] // Store discovered devices
    @Published var isCharacteristicAvailable = false // Track if characteristics are available

    private var centralManager: CBCentralManager!
    private var espPeripheral: CBPeripheral?
    private var ledCharacteristic: CBCharacteristic?

    private let serviceUUID = CBUUID(string: "5847dbc2-c4a0-4ddb-a426-17a6c4615892")
    private let characteristicUUID = CBUUID(string: "8b1523f2-cae3-41c7-b9e6-05f1e76d85db")
    
    private var lastSentValue: String?
    private var sendTimer: Timer?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            DispatchQueue.main.async { self.statusText = "Scanning for ESP32..." }
        } else {
            DispatchQueue.main.async { self.statusText = "Bluetooth not available" }
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check if the peripheral is not already in the list
        if !foundPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            foundPeripherals.append(peripheral) // Add to the list of discovered peripherals
        }
    }

    func connectToDevice(_ peripheral: CBPeripheral) {
        self.isCharacteristicAvailable = false
        espPeripheral = peripheral
        espPeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
        DispatchQueue.main.async { self.statusText = "Connecting to \(peripheral.name ?? "Train")..." }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([serviceUUID])
        DispatchQueue.main.async { self.statusText = "Connected to \(peripheral.name ?? "Train")" }
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async { self.statusText = "Failed to connect: \(error?.localizedDescription ?? "Unknown error")" }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services where service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics where characteristic.uuid == characteristicUUID {
                ledCharacteristic = characteristic
                DispatchQueue.main.async {
                    self.isCharacteristicAvailable = true // Enable buttons when characteristic is found
                }
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value, let response = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.gotResponseText = response
            }
        }
    }
    
    func sendData(_ value: String) {
        lastSentValue = value  // Store the new value
        if sendTimer == nil {
                processQueuedData()
            }
        startSendTimer()       // Start or restart the timer
    }

    private func startSendTimer() {
        if sendTimer != nil { return }

        sendTimer = Timer.scheduledTimer(withTimeInterval: 1/15.0, repeats: true) { [weak self] _ in
            self?.processQueuedData()
        }
    }

    private func stopSendTimer() {
        sendTimer?.invalidate()
        sendTimer = nil
    }

    private func processQueuedData() {
        guard let espPeripheral = espPeripheral, let characteristic = ledCharacteristic, let value = lastSentValue else {
            stopSendTimer() // Stop sending if no new data
            return
        }

        let data = value.data(using: .utf8)!
        espPeripheral.writeValue(data, for: characteristic, type: .withResponse)
        DispatchQueue.main.async { self.statusText = "Sent \(value) to Train" }

        lastSentValue = nil // Clear after sending
    }
}
