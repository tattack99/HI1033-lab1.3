//
//  ExternalSensorScreen.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-14.
//

import SwiftUI

struct ExternalSensorScreen: View {
    @EnvironmentObject var viewModel : ViewModel
    @State private var showShareSheet = false
    @State private var fileURL: URL?
  
    var body: some View {
        VStack{
            
            Text("Size_Filter:\(viewModel.filteredData.count), Size_Combo:\(viewModel.combinedData.count)")
            Text(viewModel.bluetoothStatus)
            if viewModel.isConnected {
                Text("connected")
            }
            else {
                Text("not connected")
            }
            if viewModel.failedToConnect {
                Text("failed to connect")
            }
            else {
                Text("did not fail")
            }

            ChartHeaderView()
            ChartView(combinedData: viewModel.combinedData, filteredData: viewModel.filteredData)
            AngelsView(combinedData: viewModel.combinedData, filteredData: viewModel.filteredData)
            
            
            if(!viewModel.isOverExternal()){
                AppButtonView(title: "Stop", action: {
                    viewModel.stopExternalSensor()
                })
             
            }else
            {
                AppButtonView(title: "Export reuslt", action: {
                    viewModel.saveCSV(filterData: viewModel.filteredData, combineData: viewModel.combinedData)
                    showShareSheet = true
                })
                .sheet(isPresented: $showShareSheet) {
                    FileListView()
                }
            }

            Text("External sensor")
        }
        .onAppear(perform: {
            viewModel.startExternalSensor()
        })
        .onDisappear(perform: {
            viewModel.stopExternalSensor()
        })
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Connection Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
        
    }
    
}
