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
    
    private var externalSensor: BluetoothConnect
    private var storage : PersistenceController
    private var fileMangaer : FileManageModel
    @Published private var internalSensor: MotionManagerModel
    private var time = 0
    private var cancellables = Set<AnyCancellable>()
    
    
    @Published var discoveredPeripherals : [CBPeripheral] = []
    @Published var bluetoothStatus : CBManagerState = .unknown
    @Published var peripheralState: CBPeripheralState = .disconnected
    @Published var failedToConnect = false
    @Published var filteredData: [ChartData] = []
    @Published var combinedData: [ChartData] = []
    
    init() {
        externalSensor = BluetoothConnect()
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
        externalSensor.connectToPeripheral(peripheral)
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
    
    func startExternalSensor(){
        externalSensor.startExternalSensor()
    }

    
    func stopExternalSensor(){
        externalSensor.stopExternalSensor()
    }

    
    func isOverExternal() -> Bool {
        return externalSensor.isOverExternal()
    }
    
    func listFilesFromDocumentsFolder() -> [String] {
        fileMangaer.listFilesFromDocumentsFolder()
    }
    
    func readFilteredChartData(_ fileName: String) -> [ChartData] {
        fileMangaer.readFilteredChartDataArray(fileName)
    }
    func readCombinedChartData(_ fileName: String) -> [ChartData] {
        fileMangaer.readCombinedChartDataArray(fileName)
    }
    
    func saveCSV(filterData: [ChartData],combineData: [ChartData]) {
        fileMangaer.saveCSV(filteredData: filterData, combinedData: combineData)
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
        externalSensor.failedToConnect = { [weak self] status in
            self?.failedToConnect = status
        }
        externalSensor.onPeripheralStateChanged = { [weak self] state in
            self?.peripheralState = state
        }
        externalSensor.$filteredData
            .sink { [weak self] newChartData in
                self?.filteredData = newChartData
            }
            .store(in: &cancellables)
        
        externalSensor.$combinedData
            .sink { [weak self] newChartData in
                self?.combinedData = newChartData
            }
            .store(in: &cancellables)
    }
    
}
