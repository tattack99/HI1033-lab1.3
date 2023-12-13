//
//  Angels.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//

import SwiftUI

struct AngelsView: View {
    var combinedData: [ChartData]
    var filteredData: [ChartData]
        
    var body: some View {
        HStack {
            Spacer()
            if let lastCombinedData = combinedData.last {
                Text("\(Int(lastCombinedData.degree))°").font(.system(size: 80))
            } else {
                Text("No combined data").font(.title)
            }
            Spacer()
            if let lastFilteredData = filteredData.last {
                Text("\(Int(lastFilteredData.degree))°").font(.system(size: 80))
            } else {
                Text("No filtered data").font(.title)
            }
            Spacer()
        }
    }
}
