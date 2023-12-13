//
//  Angels.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//

import SwiftUI

struct AngelsView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        HStack{
            Spacer()
            if let lastCombinedData = viewModel.combinedData.last {
                    Text("\(Int(lastCombinedData.degree))°").font(.system(size: 80))
                } else {
                    Text("No combined data").font(.title)
                }
                Spacer()
                if let lastFilteredData = viewModel.filteredData.last {
                    Text("\(Int(lastFilteredData.degree))°").font(.system(size: 80))
                } else {
                    Text("No filtered data").font(.title)
                }
            Spacer()
        }
    }
}
