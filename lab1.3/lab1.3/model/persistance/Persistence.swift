//
//  Persistence.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import CoreData

struct MyItem : Hashable{
    var timestamp : Date
}

struct PersistenceController {
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "lab1_3")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading from core data: \(error)")
            }
            else {
                print("Successfully loaded core data!")
            }
        }
    }
    
    func createEntity() async {
        let context = container.newBackgroundContext()
        await context.perform {
            let newEntity = ItemEntity(context: context)
            newEntity.timestamp = Date.now
            do {
                try context.save()
                // print("Created entity \(context) + \(String(describing: newEntity.timestamp))")
            } catch {
                print("Failed to create entity: \(error)")
            }
        }
    }

    
    func loadEntities() async -> [MyItem] {
        let context = container.newBackgroundContext()
        return await context.perform {
            let fetchRequest: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
            do {
                let entities = try context.fetch(fetchRequest)
                return entities.compactMap { entity in
                    guard let timestamp = entity.timestamp else { return nil }
                    return MyItem(timestamp: timestamp)
                }
            } catch {
                print("Failed to fetch entities: \(error)")
                return []
            }
        }
    }


    
    func deleteEntity(entity: MyItem) async {
        let context = container.newBackgroundContext()
        await context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ItemEntity")
            // Use a property of MyItem to find the corresponding Core Data entity
            fetchRequest.predicate = NSPredicate(format: "timestamp == %@", entity.timestamp as CVarArg)

            do {
                let results = try context.fetch(fetchRequest)
                if let objectToDelete = results.first as? NSManagedObject {
                    context.delete(objectToDelete)
                    try context.save()
                    //print("Entity deleted successfully.")
                } else {
                    print("No matching object found.")
                }
            } catch {
                print("Failed to delete entity: \(error)")
            }
        }
    }

    
    
    func clearCoreDataStore() {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else { return }

        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            print("Error clearing Core Data store: \(error)")
        }
    }
}
