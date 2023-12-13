//
//  Model.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import Foundation
import CoreData
import CoreBluetooth

class Model {
    
    private var polar: BluetoothConnect
    private var storage : PersistenceController
    
    @Published var discoveredPeripherals : [CBPeripheral] = []
    @Published var bluetoothStatus : CBManagerState = .unknown
    @Published var peripheralState: CBPeripheralState = .disconnected

        init() {
            polar = BluetoothConnect()
            storage = PersistenceController()
            initBluetoothConnect()
        }
        
        func createEntity() async {
            await storage.createEntity()
        }
        
        func loadEntities() async -> [MyItem] {
            await storage.loadEntities()
        }
        
        func deleteEntity(entity: MyItem) async {
            await storage.deleteEntity(entity: entity)
        }
        
        func connectToPeripheral(_ peripheral: CBPeripheral) {
            polar.connectToPeripheral(peripheral)
        }
        
        private func initBluetoothConnect(){
            polar.onPeripheralDiscovered = { [weak self] peripheral in
                if !(self?.discoveredPeripherals.contains(peripheral) ?? false) {
                    self?.discoveredPeripherals.append(peripheral)
                }
            }
            polar.onBluetoothStatusChanged = { [weak self] status in
                self?.bluetoothStatus = status
            }
            polar.onPeripheralStateChanged = { [weak self] state in
                self?.peripheralState = state
            }
        }
        
    }

