//
//  FileListView.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-14.
//

import SwiftUI

struct FileListView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var fileNames: [String] = []
    @State private var combinedData: [ChartData] = []
    @State private var filteredData: [ChartData] = []
    @State private var showingDetail = false


    
    var body: some View {
        HStack {
            Text("History")
                .font(.title)
                .padding()
                .padding(.bottom, 0)
            Spacer()
        }
        
        List(fileNames, id: \.self) { fileName in
            Button(fileName) {
                filteredData = viewModel.readFilteredChartData(fileName)
                combinedData = viewModel.readCombinedChartData(fileName)
                showingDetail = true
                
            }
        }
        .onAppear {
            fileNames = viewModel.listFilesFromDocumentsFolder().sorted(by: { first, second in
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
               
               // Parse dates from file names
               if let firstDate = dateFormatter.date(from: first),
                  let secondDate = dateFormatter.date(from: second) {
                   return firstDate > secondDate // Sort in descending order
               }
               return false
           })
        }
        .sheet(isPresented: $showingDetail) {
            HStack {
                Text("Chart")
                    .font(.title)
                    .padding()
                    .padding(.bottom, 0)
                Spacer()
            }
           ChartView(combinedData: combinedData, filteredData: filteredData)
        }
    }
}
