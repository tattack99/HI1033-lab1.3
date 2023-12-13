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
    @Binding var chartData: [ChartData]
    
    var body: some View {
        Chart {
            ForEach(chartData) { d in
                LineMark(
                    x: .value("Time", d.time),
                    y: .value("Degree", d.degree)
                )
            }
        }
    }
}

