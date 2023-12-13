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

    @EnvironmentObject var viewModel : ViewModel
    
    var body: some View {
        GeometryReader { geometry in
            Chart {
                ForEach(viewModel.filteredData) { f in
                    LineMark(
                        x: .value("Time", f.time),
                        y: .value("Degree", f.degree),
                        series: .value("pm25", "A")
                    )
                    .foregroundStyle(.blue)
                }

                ForEach(viewModel.combinedData) { c in
                    LineMark(
                        x: .value("Time", c.time),
                        y: .value("Degree", c.degree),
                        series: .value("pm10", "B")
                    )
                    .foregroundStyle(.red)
                }
            }
//            .frame(height: geometry.size.height * 0.6) // Set the height to 50% of the available space
        }
    }
}


