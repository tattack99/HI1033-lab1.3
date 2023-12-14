//
//  InterSensorScreen.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//


import SwiftUI
import Combine

struct InternalSensorScreen: View {
    @EnvironmentObject var viewModel : ViewModel
    @State private var showShareSheet = false
    @State private var fileURL: URL?
  
    
    var body: some View {
        VStack{
            
            ChartHeaderView()
            ChartView(combinedData: viewModel.combinedData, filteredData: viewModel.filteredData)
            AngelsView(combinedData: viewModel.combinedData, filteredData: viewModel.filteredData)
            
            
            if(!viewModel.isOver()){
                AppButtonView(title: "Stop", action: {
                    viewModel.stopInternalSensor()
                })
             
            }else
            {
                AppButtonView(title: "Export reuslt", action: {
                    viewModel.saveCSV(chartDataArray: viewModel.filteredData)
                    showShareSheet = true
                    // Get the file URL for test
//                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//                    fileURL = paths[0].appendingPathComponent(filename)
                    
 
                })
                .sheet(isPresented: $showShareSheet) {

                    FileListView()
                }
            }

            Text("Internal sensor")
        }
        .onAppear(perform: {
            viewModel.startInternalSensor()
        })
        .onDisappear(perform: {
            viewModel.stopInternalSensor()
        })
    }
    

}

