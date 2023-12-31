//
//  ViewModel.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import Foundation
import CoreData
import CoreBluetooth
import Combine


// Our device: C07A572F

class ViewModel : ObservableObject{
    private var hasConnectedOnce = false // Flag to track if connected once
    @Published private var model : Model
    private var cancellables = Set<AnyCancellable>()
    
    
    @Published var items: [MyItem] = []
    @Published var bluetoothDevices: [CBPeripheral] = []
    @Published var bluetoothStatus : String = "unknown"
    @Published var failedToConnect = false
    @Published var showAlert = false
    @Published var isConnected = false
    @Published var alertMessage = ""
    @Published var filteredData: [ChartData] = []
    @Published var combinedData: [ChartData] = []
    
    
    
    
    init(){
        model = Model()
        loadItems()
        initChartData()
        initExternalBluetooth()
    }
    
    func loadItems() {
        Task{
            let fetchedItems = await model.loadEntities()
            DispatchQueue.main.async {
                self.items = fetchedItems
            }
        }
    }
    
    func createEntity() {
        Task{
            await model.createEntity()
            self.loadItems()
        }
    }
    
    func deleteEntity(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        Task {
            let itemToDelete = items[index]
            await model.deleteEntity(entity: itemToDelete)
            self.loadItems()
        }
    }
    
    func connectToBluetoothDevice(to peripheral: CBPeripheral) {
        print("viewModel.connectToBluetoothDevice")
        model.connectToPeripheral(peripheral)
    }
    
    
  
    func saveCSV(filterData: [ChartData],combineData: [ChartData]) {
        model.saveCSV(filterData: filterData, combineData: combineData)
    }

    
    func listFilesFromDocumentsFolder() -> [String] {
        return model.listFilesFromDocumentsFolder()
    }
    
    func readFilteredChartData(_ fileName: String) -> [ChartData] {
        model.readFilteredChartData(fileName)
    }
    func readCombinedChartData(_ fileName: String) -> [ChartData] {
        model.readCombinedChartData(fileName)
    }
    
    
    func startInternalSensor(){
        model.startInternalSensor()
    }
  
    
    func stopInternalSensor(){
        self.objectWillChange.send()
        model.stopInternalSensor()
    }
    
  
    func isOver() -> Bool {
        return model.isOver()
    }
    
    func startExternalSensor(){
        model.startExternalSensor()
    }
  
    
    func stopExternalSensor(){
        model.stopExternalSensor()
        isConnected = false
    }
    
  
    func isOverExternal() -> Bool {
        return model.isOverExternal()
    }
    
    
    private func initChartData(){
        model.$filteredData
            .sink { [weak self] newChartData in
                self?.filteredData = newChartData
            }
            .store(in: &cancellables)
        
        model.$combinedData
            .sink { [weak self] newChartData in
                self?.combinedData = newChartData
            }
            .store(in: &cancellables)
    }
    
    private func initExternalBluetooth() {
        model.$discoveredPeripherals
            .receive(on: RunLoop.main)
            .assign(to: &$bluetoothDevices)
        model.$failedToConnect
            .receive(on: RunLoop.main)
            .assign(to: &$failedToConnect)
        model.$bluetoothStatus.map { status in
            switch status {
            case .poweredOn:
                return "Bluetooth is On"
            case .poweredOff:
                return "Bluetooth is Off"
            case .unauthorized:
                return "Bluetooth is Unauthorized"
            default:
                return "Bluetooth State: \(status)"
            }
        }
        .receive(on: RunLoop.main)
        .assign(to: &$bluetoothStatus)
        model.$peripheralState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                
                if state == .connected {
                    self?.hasConnectedOnce = true
                    print("connected to device!!!")
                    self?.isConnected = true
                } else if state == .disconnected && self?.hasConnectedOnce == true {
                    self?.alertMessage = "Polar device disconnected."
                    self?.showAlert = true
                    self?.isConnected = false
                }
            }
            .store(in: &cancellables)
        model.$failedToConnect
            .receive(on: RunLoop.main)
            .assign(to: \.failedToConnect, on: self)
            .store(in: &cancellables)
        
        
    }
}
    

