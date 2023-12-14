//
//  ChartView.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//

import SwiftUI
import Charts

struct ChartData: Identifiable  {
    let id = UUID()
    var time: Double
    var degree: Double
}

struct ChartView: View {

    var combinedData: [ChartData]
    var filteredData: [ChartData]
        
    var body: some View {
        Chart {
            ForEach(filteredData) { f in
                LineMark(
                    x: .value("Time", f.time),
                    y: .value("Degree", f.degree),
                    series: .value("pm25", "A")
                )
                .foregroundStyle(.blue)
            }

            ForEach(combinedData) { c in
                LineMark(
                    x: .value("Time", c.time),
                    y: .value("Degree", c.degree),
                    series: .value("pm10", "B")
                )
                .foregroundStyle(.red)
            }
        }
    }
}


