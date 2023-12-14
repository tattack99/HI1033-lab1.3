//
//  Model.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import Foundation
import CoreData
import CoreBluetooth
import Combine

class Model {
    
    private var externalSensor: BluetoothConnect
    private var storage : PersistenceController
    private var internalSensor: MotionManagerModel
    private var time = 0
    private var cancellables = Set<AnyCancellable>()
    
    
    @Published var discoveredPeripherals : [CBPeripheral] = []
    @Published var bluetoothStatus : CBManagerState = .unknown
    @Published var peripheralState: CBPeripheralState = .disconnected
    @Published var filteredData: [ChartData] = []
    @Published var combinedData: [ChartData] = []
    
    
    init() {
        storage = PersistenceController()
        internalSensor = MotionManagerModel()
        externalSensor = BluetoothConnect()
        initChartData()
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
        externalSensor.connectToPeripheral(peripheral)
    }
    
    func startInternalSensor(){
        internalSensor.startMotionUpdates()
    }
    
    func stopInternalSensor(){
        internalSensor.stopMotionUpdates()
    }
    
    func startExternalSensor(){
        // TODO: Implement start
    }
    
    func stopExternalSensor(){
        // TODO: Implement stop
    }
    
    
    private func initChartData(){
        internalSensor.$filteredData
            .sink { [weak self] newChartData in
                self?.filteredData = newChartData
            }
            .store(in: &cancellables)
        
        internalSensor.$combinedData
            .sink { [weak self] newChartData in
                self?.combinedData = newChartData
            }
            .store(in: &cancellables)
    }
    
    private func initBluetoothConnect(){
        externalSensor.onPeripheralDiscovered = { [weak self] peripheral in
            if !(self?.discoveredPeripherals.contains(peripheral) ?? false) {
                self?.discoveredPeripherals.append(peripheral)
            }
        }
        externalSensor.onBluetoothStatusChanged = { [weak self] status in
            self?.bluetoothStatus = status
        }
        externalSensor.onPeripheralStateChanged = { [weak self] state in
            self?.peripheralState = state
            
        }
    }
    
}
