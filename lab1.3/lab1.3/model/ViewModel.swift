//
//  ViewModel.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import Foundation
import CoreData
import CoreBluetooth

// Our device: C07A572F

class ViewModel : ObservableObject{
    
    @Published var items: [MyItem] = []
    @Published var bluetoothDevices: [CBPeripheral] = []
    
    private var model : Model
    
    
    
    init(){
        model = Model()
        loadItems()
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
    
    private func initExternalBluetooth() {
        model.$discoveredPeripherals
            .receive(on: RunLoop.main)
            .assign(to: &$bluetoothDevices)
        }
        
}

