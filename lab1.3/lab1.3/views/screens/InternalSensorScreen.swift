//
//  InterSensorScreen.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//


import SwiftUI

struct InternalSensorScreen: View {
    let model = MotionManagerModel()
    var body: some View {
        Text("Internal sensor")
            .onAppear(perform: {
                model.startMotionUpdates()
            })
            .onDisappear(perform: {
                model.stopMotionUpdates()
            })
    }
}

struct InternalSensorScreen_Previews: PreviewProvider {
    static var previews: some View {
        InternalSensorScreen()
    }
}
