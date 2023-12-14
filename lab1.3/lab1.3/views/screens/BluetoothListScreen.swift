//
//  BluetoothListScreen.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//

import SwiftUI


struct BluetoothListScreen: View {
    @EnvironmentObject var viewModel : ViewModel
    
    var body: some View {
        VStack{
            Text(viewModel.bluetoothStatus)
            List(viewModel.bluetoothDevices, id: \.identifier) { device in
                NavigationLink(destination: ExternalSensorScreen()) {
                    Text(device.name ?? "Unknown Device")
                        .onTapGesture {
                            viewModel.connectToBluetoothDevice(to: device)
                        }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Connection Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        
    }
}

struct BluetoothListScreen_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothListScreen()
    }
}
