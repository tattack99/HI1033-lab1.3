//
//  ChartHeader.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//

import SwiftUI

struct ChartHeaderView: View {
    var body: some View {
        VStack  {
            Text("Chart").font(.title)
            HStack{
                Spacer()
                HStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 30)
                        .frame(height: 4)
                    Text("Combined")
                        .font(.headline)
                     
                }
                Spacer()
                HStack {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 30)
                        .frame(height: 4)
                    Text("Filtered")
                        .font(.headline)
                       
                }
                Spacer()
            }
        }
        .padding(.vertical, 10)
    }
}

