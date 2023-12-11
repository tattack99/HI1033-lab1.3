//
//  Model.swift
//  lab1.3
//
//  Created by Tim Johansson on 2023-12-11.
//

import Foundation

struct Model {
    
    private var polar: BluetoothConnect
    
    init() {
        polar = BluetoothConnect()
        polar.start()
    }
    
}
