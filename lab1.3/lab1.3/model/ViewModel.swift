//
//  ViewModel.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import Foundation
import CoreData

class ViewModel : ObservableObject{
    
    @Published var items: [MyItem] = []
    
    private var model : Model

    
    
    init(){
        model = Model()
        loadItems()
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
            loadItems()
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


 
}

