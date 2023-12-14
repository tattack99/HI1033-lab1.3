//
//  DataProcessor.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//


import Foundation



class DataProcessor{
    
    var alpha: Double
    
    init() {
        self.alpha = 0.95
    }
    
    func applyEwmaFilter(_ input: SensorData, _ previousAccelerometerOutput: SensorData) -> SensorData {
        let filteredX = alpha * input.x + (1 - alpha) * previousAccelerometerOutput.x
        let filteredY = alpha * input.y + (1 - alpha) * previousAccelerometerOutput.y
        let filteredZ = alpha * input.z + (1 - alpha) * previousAccelerometerOutput.z

        return SensorData(x:filteredX, y:filteredY, z:filteredZ)
    }
    
    
    func applyComplementaryFilter(_ accelerometerData: SensorData, _ gyroData: SensorData) -> SensorData {
      
        let combinedX = alpha * accelerometerData.x + (1 - alpha) * gyroData.x
        let combinedY = alpha * accelerometerData.y + (1 - alpha) * gyroData.y
        let combinedZ = alpha * accelerometerData.z + (1 - alpha) * gyroData.z
        return SensorData(x:combinedX, y:combinedY, z:combinedZ)
    }
    
    
    func calculateEulerAngles(_ input: SensorData) -> (roll: Double, pitch: Double, yaw: Double) {
        
        let x = input.x
        let y = input.y
        let z = input.z
            
       let yaw: Double = 0.0
       let pitch: Double = atan2(y, sqrt(x * x + z * z)) * 180 / .pi
       let roll: Double = atan2(-x, z) * 180 / .pi

       return (roll: roll, pitch: pitch, yaw: yaw)
   }
    
    
}
