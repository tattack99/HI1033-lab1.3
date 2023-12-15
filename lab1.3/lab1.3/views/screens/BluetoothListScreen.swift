//
//  BluetoothListScreen.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//

import SwiftUI
import CoreBluetooth


struct BluetoothListScreen: View {
    @EnvironmentObject var viewModel : ViewModel
    @State private var navigateToExternalSensorScreen = false
    
    var body: some View {
        VStack{
            List(viewModel.bluetoothDevices, id: \.identifier) { device in
                Button(action: {
                    viewModel.connectToBluetoothDevice(to: device)
                }){
                    Text(device.name ?? "Unknown Device")
                }
            }
        }
        .background(NavigationLink("", destination: ExternalSensorScreen(), isActive: $viewModel.isConnected))
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Connection Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct BluetoothListScreen_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothListScreen()
    }
}
