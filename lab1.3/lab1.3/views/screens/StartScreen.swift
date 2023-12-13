//
//  StartScreen.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//

import SwiftUI

struct StartScreen: View {
    var body: some View {
        NavigationView{
            VStack{
                
                Text("What sensor do you want to use: ")
                
                HStack{
                    NavigationLink(destination: InternalSensorScreen()){
                        Text("Internal")
                            .padding()
                    }
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(10)
                    
                    
                    NavigationLink(destination: BluetoothListScreen()){
                        Text("External")
                            .padding()
                    }
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen()
    }
}
