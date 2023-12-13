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
    
    var accData: SensorData
    var gyroData: SensorData
    var peripherals: [CBPeripheral]
    var onPeripheralDiscovered: ((CBPeripheral) -> Void)?
    var onPeripheralStateChanged: ((CBPeripheralState) -> Void)?
    var onBluetoothStatusChanged: ((CBManagerState) -> Void)?

    let GATTService = CBUUID(string: "fb005c80-02e7-f387-1cad-8acd2d8df0c8")
    let GATTCommand = CBUUID(string: "fb005c81-02e7-f387-1cad-8acd2d8df0c8")
    let GATTData = CBUUID(string:    "fb005c82-02e7-f387-1cad-8acd2d8df0c8")
    
    override init(){
        print("init")
        self.accData = SensorData()
        self.gyroData = SensorData()
        self.peripherals = []
        
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
        peripheral.discoverServices(nil)
        central.scanForPeripherals(withServices: [GATTService], options: nil)
        onPeripheralStateChanged?(.connected)
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        print("Connect to Peripheral: \(String(describing: peripheral.name))")
        onPeripheralStateChanged?(.connecting)
        self.peripheralBLE = peripheral
        self.peripheralBLE?.delegate = self
        self.centralManager?.connect(peripheralBLE!, options: nil)
        self.centralManager.stopScan()
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateState newState: CBPeripheralState) {
        onPeripheralStateChanged?(peripheral.state)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        onPeripheralStateChanged?(.disconnected)
    }

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
         for service in peripheral.services!{
             print("Service Found")
             peripheral.discoverCharacteristics([GATTData, GATTCommand], for: service)
         }
     }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristics")
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == GATTData {
                print("Data")
                peripheral.setNotifyValue(true, for:characteristic)
            }
            if characteristic.uuid == GATTCommand{
                print("Command")
                
                // Gyroscope
                let gyroParameter : [UInt8]  = [0x02, 0x05, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0xD0, 0x07, 0x04, 0x01, 0x03]
                let gyroData = NSData(bytes: gyroParameter, length: gyroParameter.count)
                
                peripheral.writeValue(gyroData as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing value to characteristic: \(error)")
            return
        }

        if characteristic.uuid == GATTCommand {
            let accParameter: [UInt8] = [0x02, 0x02, 0x00, 0x01, 0x34, 0x00, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01, 0x08, 0x00, 0x04, 0x01, 0x03]
            let accData = Data(bytes: accParameter, count: accParameter.count)

            peripheral.writeValue(accData as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        print("New data")
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
    
        print("MessageID:\(measId) Time:\(timeStamp) Frame Type:\(frameType)")
        
        
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
        
        print("xRef:\(xSample >> 11) yRef:\(ySample >> 11) zRef:\(zSample >> 11)")
        
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
                    print("2")
                    self.accData.x = Double(xSample) / 4096.0
                    self.accData.y = Double(ySample) / 4096.0
                    self.accData.z = Double(zSample) / 4096.0

                    // Round to two decimal places
                    self.accData.x = (self.accData.x * 100).rounded() / 100
                    self.accData.y = (self.accData.y * 100).rounded() / 100
                    self.accData.z = (self.accData.z * 100).rounded() / 100
                    print("xDelta:\(self.accData.x) yDelta:\(self.accData.y) zDelta:\(self.accData.z)")

                case 5 :
                    print("5")
                    self.gyroData.x = Double(xSample) / 16.384
                    self.gyroData.y = Double(ySample) / 16.384
                    self.gyroData.z = Double(zSample) / 16.384

                    // Round to two decimal places
                    self.gyroData.x = (self.gyroData.x * 100).rounded() / 100
                    self.gyroData.y = (self.gyroData.y * 100).rounded() / 100
                    self.gyroData.z = (self.gyroData.z * 100).rounded() / 100
                    print("xDelta:\(self.gyroData.x) yDelta:\(self.gyroData.y) zDelta:\(self.gyroData.z)")

                default:
                    print("Other")
                }
            }
        }
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

