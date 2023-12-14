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
                Text("\(Int(lastCombinedData.degree))°").font(.system(size: 80)).foregroundColor(.red)
            } else {
                Text("N/A").font(.title).foregroundColor(.red)
            }
            Spacer()
            if let lastFilteredData = filteredData.last {
                Text("\(Int(lastFilteredData.degree))°").font(.system(size: 80)).foregroundColor(.blue)
            } else {
                Text("N/A").font(.title).foregroundColor(.blue)
            }
            Spacer()
        }
    }
}
