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
    @State private var selectedFileContents: [ChartData] = []
    @State private var showingDetail = false


    
    var body: some View {
        Text("History").font(.title)
        List(fileNames, id: \.self) { fileName in
            Button(fileName) {
                selectedFileContents = viewModel.readChartData(from:fileName)
                print(selectedFileContents)
                showingDetail = true
                
            }
        }
        .onAppear {
            fileNames = viewModel.listFilesFromDocumentsFolder()
        }
        .sheet(isPresented: $showingDetail) {
            Text("Chart")
           ChartView(combinedData: selectedFileContents, filteredData: selectedFileContents)
        }
    }
}
