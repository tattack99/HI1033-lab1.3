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
            Button(action: {
                print("Exportig...")
            }){
                Text("Export result")
                .padding()
            }
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(10)
            
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

