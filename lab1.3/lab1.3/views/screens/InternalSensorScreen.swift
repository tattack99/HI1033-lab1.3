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
                    print("Exporting...")
                })
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

