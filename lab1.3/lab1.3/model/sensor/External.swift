//
//  bluetooth.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import Foundation
import CoreBluetooth
import SwiftUI

struct SensorData {
    var x: Double = 0.0
    var y: Double = 0.0
    var z: Double = 0.0
}

class BluetoothConnect: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheralBLE: CBPeripheral!
    var gattCommandCharacteristic: CBCharacteristic?
    

    
    var accData: SensorData
    var gyroData: SensorData
    var peripherals: [CBPeripheral]
    var onPeripheralDiscovered: ((CBPeripheral) -> Void)?
    var onPeripheralStateChanged: ((CBPeripheralState) -> Void)?
    var onBluetoothStatusChanged: ((CBManagerState) -> Void)?
    var failedToConnect: ((Bool) -> Void)?


    var commandToWrite : String


    
    @Published var isOver = true
    @Published var filteredData: [ChartData] = []
    @Published var combinedData: [ChartData] = []
    
    var filteredDataOut: [ChartData] = []
    var combinedDataOut: [ChartData] = []
    private var startTime: Date?
    private var timer: DispatchSourceTimer?
    private let dataProcessor = DataProcessor()
    private var timeInterval = 0.05
    private var timeIncrement = 0.0
    private var timeEnd = 30.0

    
    let GATTService = CBUUID(string: "fb005c80-02e7-f387-1cad-8acd2d8df0c8")
    let GATTCommand = CBUUID(string: "fb005c81-02e7-f387-1cad-8acd2d8df0c8")
    let GATTData = CBUUID(string:    "fb005c82-02e7-f387-1cad-8acd2d8df0c8")
    
    override init(){
        print("init")
        self.accData = SensorData()
        self.gyroData = SensorData()
        self.peripherals = []
        self.commandToWrite = "acc"
        
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.onBluetoothStatusChanged?(central.state)
        
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("unknown")
        }
    }

    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("Discover")
                
        if let name = peripheral.name, name.contains("Polar"){
            //print("Found Polar")
            if !peripherals.contains(peripheral) {
                peripherals.append(peripheral)
                print("Added Polar to List: \(String(describing: peripheral.name))")
                onPeripheralDiscovered?(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        self.failedToConnect?(false)
        peripheral.discoverServices(nil)
        central.scanForPeripherals(withServices: [GATTService], options: nil)
        onPeripheralStateChanged?(.connected)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
         for service in peripheral.services!{
             print("Service Found")
             peripheral.discoverCharacteristics([GATTData, GATTCommand], for: service)
         }
     }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "unknown device"). Error: \(error?.localizedDescription ?? "no error information")")
        self.failedToConnect?(true)
        // Handle specific error cases if needed
        if let error = error as? CBError {
            switch error.code {
            case .unknown:
                print("Unknown error occurred.")
            case .peerRemovedPairingInformation:
                print("Peer removed pairing information.")
            default:
                print("Other error occurred: \(error.localizedDescription)")
            }
        }
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        print("Connect to Peripheral: \(String(describing: peripheral.name))")
        onPeripheralStateChanged?(.connecting)
        self.peripheralBLE = peripheral
        self.peripheralBLE?.delegate = self
        self.centralManager?.connect(peripheralBLE!, options: nil)
        onPeripheralStateChanged?(.connecting)
        self.centralManager.stopScan()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateState newState: CBPeripheralState) {
        onPeripheralStateChanged?(peripheral.state)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        onPeripheralStateChanged?(.disconnected)
    }

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor")
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == GATTData {
                print("GATTData")
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            if characteristic.uuid == GATTCommand {
                print("GATTCommand")
                self.gattCommandCharacteristic = characteristic
                
                let accParameter: [UInt8] = [0x02, 0x02, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0x08, 0x00, 0x04, 0x01, 0x03]
                let accData = Data(bytes: accParameter, count: accParameter.count)
                
                peripheral.writeValue(accData, for: characteristic, type: .withResponse)
            }
        }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing value to characteristic: \(error)")
            return
        }

        if characteristic.uuid == GATTCommand {
            let gyroParameter: [UInt8] = [0x02, 0x05, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0xD0, 0x07, 0x04, 0x01, 0x03]
            let gyroData = Data(bytes: gyroParameter, count: gyroParameter.count)
            peripheral.writeValue(gyroData, for: characteristic, type: .withResponse)
            
        }
    }
     


    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,error: Error?) {
        guard !isOver else { return }
        
        //print("New data")
        let data = characteristic.value
        var byteArray: [UInt8] = []
        for i in data! {
            let n : UInt8 = i
            byteArray.append(n)
        }
        
        //print(byteArray)
        
        var offset = 0
        let measId = data![offset]
        offset += 1
        
        let timeBytes = data!.subdata(in: 1..<9) as NSData
        var timeStamp: UInt64 = 0
        memcpy(&timeStamp,timeBytes.bytes,8)
        offset += 8
        
        let frameType = data![offset]
        offset += 1
    
        //print("MessageID:\(measId) Time:\(timeStamp) Frame Type:\(frameType)")
        
        
        let xBytes = data!.subdata(in: offset..<offset+2) as NSData
        var xSample: Int16 = 0
        memcpy(&xSample,xBytes.bytes,2)
        offset += 2
        
        let yBytes = data!.subdata(in: offset..<offset+2) as NSData
        var ySample: Int16 = 0
        memcpy(&ySample,yBytes.bytes,2)
        offset += 2
        
        let zBytes = data!.subdata(in: offset..<offset+2) as NSData
        var zSample: Int16 = 0
        memcpy(&zSample,zBytes.bytes,2)
        offset += 2
        
        //print("xRef:\(xSample >> 11) yRef:\(ySample >> 11) zRef:\(zSample >> 11)")
        
        let deltaSize = UInt16(data![offset])
        offset += 1
        let sampleCount = UInt16(data![offset])
        offset += 1
        
        print("deltaSize:\(deltaSize) Sample Count:\(sampleCount)")

        let bitLength = (sampleCount*deltaSize*UInt16(3))
        let length = Int(ceil(Double(bitLength)/8.0))
        let frame = data!.subdata(in: offset..<(offset+length))

        let deltas = BluetoothConnect.parseDeltaFrame(frame, channels: UInt16(3), bitWidth: deltaSize, totalBitLength: bitLength)
        
        deltas.forEach { (delta) in
            xSample = xSample + delta[0];
            ySample = ySample + delta[1];
            zSample = zSample + delta[2];
            
            //print("xDelta:\(xSample) yDelta:\(ySample) zDelta:\(zSample)")
            
            DispatchQueue.main.async {
                
                switch measId {
                case 2 :
                    let rawAccData = SensorData(x: Double(xSample) / 4096.0, y: Double(ySample) / 4096.0, z: Double(zSample) / 4096.0)
                    self.processAccData(sensorData : rawAccData)
                case 5 :
                    let rawGyroData = SensorData(x: Double(xSample) / 16.384, y: Double(ySample) / 16.384, z: Double(zSample) / 16.384)
                    self.processGyroData(sensorData : rawGyroData)
                    
                default:
                    print("Other")
                }
            }
        }
    }
    
    func processAccData(sensorData: SensorData) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }

            // Perform the data processing in the background
            let filteredAccData = strongSelf.dataProcessor.applyEwmaFilter(sensorData, strongSelf.accData)
            let angles = strongSelf.dataProcessor.calculateEulerAngles(filteredAccData)

            let result = Int(angles.pitch + 90) % 360
            let elapsedTime = Date().timeIntervalSince(strongSelf.startTime ?? Date())

            // Once processing is done, update the UI on the main thread
            DispatchQueue.main.async {
                strongSelf.filteredData.append(ChartData(time: Double(elapsedTime), degree: Double(result)))
                if elapsedTime >= strongSelf.timeEnd {
                    strongSelf.stopExternalSensor()
                }
            }
        }
    }
    
    
    func processGyroData(sensorData: SensorData) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }

            // Perform the data processing in the background
            let combData = strongSelf.dataProcessor.applyComplementaryFilter(strongSelf.accData, sensorData)
            let angles = strongSelf.dataProcessor.calculateEulerAngles(combData)
            let result = Int(angles.pitch + 90) % 360
            let elapsedTime = Date().timeIntervalSince(strongSelf.startTime ?? Date())

            // Once processing is done, update the UI on the main thread
            DispatchQueue.main.async {
                strongSelf.combinedData.append(ChartData(time: Double(elapsedTime), degree: Double(result)))
                if elapsedTime >= strongSelf.timeEnd {
                    strongSelf.stopExternalSensor()
                }
            }
        }
    }

    
    func startExternalSensor(){
        reset()
        isOver = false
        startTime = Date()  // Set the start time to the current time
    }

    
    func stopExternalSensor(){
        DispatchQueue.main.async { [weak self] in
            self?.isOver = true
            self?.disconnectFromSensor()
            self?.timer?.cancel()
            self?.timer = nil
        }
    }
    
    func reset(){
        filteredData = []
        combinedData = []
        filteredDataOut = []
        combinedDataOut = []
        timeIncrement = 0.0
    }

    
    func isOverExternal() -> Bool {
        return isOver
    }
    
    func disconnectFromSensor() {
        print("disconnectFromSensor")
        guard let characteristic = gattCommandCharacteristic else { return }
        let command: [UInt8] = [0x02, 0x02] // Disconnection command
        let commandData = Data(bytes: command, count: command.count)
        peripheralBLE.writeValue(commandData, for: characteristic, type: .withResponse)
    }
    
   
    static func parseDeltaFrame(_ data: Data, channels: UInt16, bitWidth: UInt16, totalBitLength: UInt16) -> [[Int16]]{
        // convert array to bits
        let dataInBits = data.flatMap { (byte) -> [Bool] in
            return Array(stride(from: 0, to: 8, by: 1).map { (index) -> Bool in
                return (byte & (0x01 << index)) != 0
            })
        }
        
        let mask = Int16.max << Int16(bitWidth-1)
        let channelBitsLength = bitWidth*channels
        
        return Array(stride(from: 0, to: totalBitLength, by: UInt16.Stride(channelBitsLength)).map { (start) -> [Int16] in
            return Array(stride(from: start, to: UInt16(start+UInt16(channelBitsLength)), by: UInt16.Stride(bitWidth)).map { (subStart) -> Int16 in
                let deltaSampleList: ArraySlice<Bool> = dataInBits[Int(subStart)..<Int(subStart+UInt16(bitWidth))]
                var deltaSample: Int16 = 0
                var i=0
                deltaSampleList.forEach { (bitValue) in
                    let bit = Int16(bitValue ? 1 : 0)
                    deltaSample |= (bit << i)
                    i += 1
                }
                
                if((deltaSample & mask) != 0) {
                    deltaSample |= mask;
                }
                return deltaSample
            })
        })
    }

}

