//
//  ButtonView.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//

import SwiftUI

struct ButtonView: View {
    var text: String
    var body: some View {
        NavigationLink(destination: InternalSensorScreen()){
            Text(text)
                .padding()
        }
        .foregroundColor(.white)
        .background(.blue)
        .cornerRadius(10)
    }
}

