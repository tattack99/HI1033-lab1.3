//
//  MacOSView.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-12.
//

import SwiftUI

struct MacOSView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack{
            Text(viewModel.bluetoothStatus)
            List(viewModel.bluetoothDevices, id: \.identifier) { device in
                Button(action: {
                    viewModel.connectToBluetoothDevice(to: device)
                }) {
                    Text(device.name ?? "Unknown Device")
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Connection Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        
    }
    
    struct MacOSView_Previews: PreviewProvider {
        static var previews: some View {
            MacOSView().environmentObject(ViewModel())
        }
    }
}
