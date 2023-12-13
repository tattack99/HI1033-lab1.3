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
            ChartView(chartData: $viewModel.chartData)
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

