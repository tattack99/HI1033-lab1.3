//
//  Internal.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//

import Foundation
import CoreMotion

class MotionManagerModel {
    private let motionManager = CMMotionManager()
    private let dataProcessor = DataProcessor()
    private var lastAccelerometerOutput = SensorData(x: 0, y: 0, z: 0)
    private var lastGyroOutput = SensorData(x: 0, y: 0, z: 0)
    private var time = 0
    private var maxTime = 300
    
    @Published var filteredData: [ChartData] = []
    @Published var combinedData: [ChartData] = []
  

    func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable, motionManager.isGyroAvailable else {
            print("Required sensors are not available.")
            return
        }

        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.gyroUpdateInterval = 0.1

        startAccelerometerUpdates()
        startGyroUpdates()
    }

    private func startAccelerometerUpdates() {
   
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
            guard let self = self, let accelerometerData = data, error == nil else {
                print("Error: \(error!)")
                return
            }
            
            
            let accelerationData = SensorData(
                x:accelerometerData.acceleration.x,
                y:accelerometerData.acceleration.y,
                z:accelerometerData.acceleration.z
            )

            let filtData = dataProcessor.applyEwmaFilter(accelerationData, lastAccelerometerOutput)
            
            let angels = dataProcessor.calculateEulerAngles(filtData)
            
            lastAccelerometerOutput = filtData
                
//            print("Filtered: roll: \(Int(angels.roll )%360), pitch: \(Int(angels.pitch + 90)%360), yaw: \(angels.yaw)" )
            let result = Int(angels.pitch + 90) % 360
            filteredData.append(ChartData(time: Double(time), degree: Double(result)))
            time = time + 1
            if(time >= maxTime){
                stopMotionUpdates()
            }
            
        }

    }

    private func startGyroUpdates() {
        motionManager.startGyroUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
            guard let self = self, let gyroData = data, error == nil else {
                print("Error: \(error!)")
                return
            }

            
            let gyroOutput = SensorData(
                x:gyroData.rotationRate.x,
                y:gyroData.rotationRate.y,
                z:gyroData.rotationRate.z
            )

            let combData = dataProcessor.applyComplementaryFilter(lastAccelerometerOutput, gyroOutput)
        
            let angels = dataProcessor.calculateEulerAngles(combData)

//            print("Combined: roll: \(Int(angels.roll)%360), pitch: \(Int(angels.pitch + 90)%360), yaw: \(angels.yaw)\n")
            
            let result = Int(angels.pitch + 90) % 360
            combinedData.append(ChartData(time: Double(time), degree: Double(result)))
        }
    }

 

    
    func stopMotionUpdates(){
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        // TODO save the data in presistence
        combinedData = []
        filteredData = []
        time = 0
    }
    
    
    deinit {
        stopMotionUpdates()
    }
}
