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
    private var model : Model
    private var cancellables = Set<AnyCancellable>()
    
    
    @Published var items: [MyItem] = []
    @Published var bluetoothDevices: [CBPeripheral] = []
    @Published var bluetoothStatus : String = "unknown"
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var filteredData: [ChartData] = []
    @Published var combinedData: [ChartData] = []
    
    
    
    
    init(){
        model = Model()
        loadItems()
        initChartData()
        initExternalBluetooth()
        saveCSV(csvString: "String", filename: "fileName")
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
        model.connectToPeripheral(peripheral)
    }
    
    func saveCSV(csvString: String, filename: String) {
        let data = [
            ["Name", "Age", "City"],
            ["Alice", "28", "New York"],
            ["Bob", "22", "San Francisco"]
        ]
        
        let csvString = data.map { row in
            row.joined(separator: ",")
        }.joined(separator: "\n")
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent(filename)
        
        do {
            print("csvString: \(csvString)")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV file saved: \(fileURL)")
        } catch {
            print("Error saving file: \(error)")
        }
    }
    func startInternalSensor(){
        model.startInternalSensor()
    }
    
    func stopInternalSensor(){
        model.stopInternalSensor()
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
                
                if state == .connecting {
                    self?.hasConnectedOnce = true
                    print("connect to device!!!")
                } else if state == .disconnected && self?.hasConnectedOnce == true {
                    self?.alertMessage = "Polar device disconnected."
                    self?.showAlert = true
                }
            }
            .store(in: &cancellables)
        
    }
}
    

