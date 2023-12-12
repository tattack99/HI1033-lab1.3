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
        List(viewModel.bluetoothDevices, id: \.identifier) { device in
            Button(action: {
                viewModel.connectToBluetoothDevice(to: device)
            }) {
                Text(device.name ?? "Unknown Device")
            }
        }
    }
    
    struct MacOSView_Previews: PreviewProvider {
        static var previews: some View {
            MacOSView().environmentObject(ViewModel())
        }
    }
}
