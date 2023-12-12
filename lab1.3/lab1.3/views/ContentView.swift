//
//  ContentView.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items, id: \.self) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, formatter: itemFormatter)")
                        } label: {
                       Text(item.timestamp, formatter: itemFormatter)
                   }
                }
                .onDelete(perform: { offsets in
                    viewModel.deleteEntity(at: offsets)
                })
                }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { viewModel.createEntity()}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
            }
        }
    
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewModel())
    }
}
