//
//  AppButtonView.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-14.
//

import SwiftUI

struct AppButtonView: View {
    var title: String
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            action?()
        }){
            Text(title)
                .padding()
        }
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(10)
    }
    
}
