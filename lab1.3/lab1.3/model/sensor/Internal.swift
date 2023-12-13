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
    private var maxTime = 0
    @Published var chartData: [ChartData] = []
    
  

    func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable, motionManager.isGyroAvailable else {
            print("Required sensors are not available.")
            return
        }

        motionManager.accelerometerUpdateInterval = 1.0
        motionManager.gyroUpdateInterval = 1.0

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

            let filteredData = dataProcessor.applyEwmaFilter(accelerationData, lastAccelerometerOutput)
            
            let angels = dataProcessor.calculateEulerAngles(filteredData)
            
            lastAccelerometerOutput = filteredData
                
            print("Filtered: roll: \(Int(angels.roll )%360), pitch: \(Int(angels.pitch + 90)%360), yaw: \(angels.yaw)" )
            let result = Int(angels.pitch + 90) % 360
            chartData.append(ChartData(time: Double(time), degree: Double(result)))
            time = time + 1
            
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

            let combinedData = dataProcessor.applyComplementaryFilter(lastAccelerometerOutput, gyroOutput)
        
            let angels = dataProcessor.calculateEulerAngles(combinedData)

            print("Combined: roll: \(Int(angels.roll)%360), pitch: \(Int(angels.pitch + 90)%360), yaw: \(angels.yaw)\n")
        }
    }

 

    
    func stopMotionUpdates(){
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
    
    
    deinit {
        stopMotionUpdates()
    }
}
