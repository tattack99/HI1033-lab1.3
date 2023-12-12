//
//  Model.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import Foundation
import CoreData

struct Model {
    
    private var polar: BluetoothConnect
    private var storage : PersistenceController

    
    init() {
        polar = BluetoothConnect()
        storage = PersistenceController()
        
        //polar.start()
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
    
}

