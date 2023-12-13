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
    
    @Published var items: [MyItem] = []
    @Published var bluetoothDevices: [CBPeripheral] = []
    @Published var chartData: [ChartData] = []
    private var model : Model
    private var cancellables = Set<AnyCancellable>()

    
    
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
        model.connectToPeripheral(peripheral)
    }
    
    func startInternalSensor(){
        model.startInternalSensor()
    }
    
    func stopInternalSensor(){
        model.stopInternalSensor()
    }
    
    private func initChartData(){
        model.$chartData
           .sink { [weak self] newChartData in
               self?.chartData = newChartData
           }
           .store(in: &cancellables)
    }
    
    private func initExternalBluetooth() {
        model.$discoveredPeripherals
            .receive(on: RunLoop.main)
            .assign(to: &$bluetoothDevices)
        }
        
}

