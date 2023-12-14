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

class Model: ObservableObject {
    
    private var polar: BluetoothConnect
    private var storage : PersistenceController
    private var fileMangaer : FileManageModel
    @Published private var internalSensor: MotionManagerModel
    private var time = 0
    private var cancellables = Set<AnyCancellable>()
    
    
    @Published var discoveredPeripherals : [CBPeripheral] = []
    @Published var bluetoothStatus : CBManagerState = .unknown
    @Published var peripheralState: CBPeripheralState = .disconnected
    @Published var filteredData: [ChartData] = []
    @Published var combinedData: [ChartData] = []
    
    init() {
        polar = BluetoothConnect()
        storage = PersistenceController()
        internalSensor = MotionManagerModel()
        fileMangaer = FileManageModel()
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
        polar.connectToPeripheral(peripheral)
    }
    
    func startInternalSensor(){
        internalSensor.startMotionUpdates()
    }

    
    func stopInternalSensor(){
        internalSensor.stopMotionUpdates()
    }

    
    func isOver() -> Bool {
        return internalSensor.isOver
    }
    
    func listFilesFromDocumentsFolder() -> [String] {
        fileMangaer.listFilesFromDocumentsFolder()
    }
    
    func readChartData(_ fileName: String) -> [ChartData] {
        fileMangaer.readChartData(fileName)
    }
    
    func saveCSV(chartDataArray: [ChartData]) {
        fileMangaer.saveCSV(chartDataArray: chartDataArray)
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
