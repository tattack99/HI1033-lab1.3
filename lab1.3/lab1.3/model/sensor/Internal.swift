//
//  Internal.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-13.
//

import Foundation
import CoreMotion

class MotionManagerModel: ObservableObject {
    private let motionManager = CMMotionManager()
    private let dataProcessor = DataProcessor()
    private var lastAccelerometerOutput = SensorData(x: 0, y: 0, z: 0)
    private var lastGyroOutput = SensorData(x: 0, y: 0, z: 0)
    private let updatedInterval = 0.1 // in seconds
    private let duration = 30.0 // total duration in seconds
    private var timer: DispatchSourceTimer?
    private var startTime: Date?

    @Published var isOver = false
    @Published var filteredData: [ChartData] = []
    @Published var combinedData: [ChartData] = []
    

    func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable, motionManager.isGyroAvailable else {
            print("Required sensors are not available.")
            return
        }

        startTime = Date()

        motionManager.accelerometerUpdateInterval = updatedInterval
        motionManager.gyroUpdateInterval = updatedInterval

        startTimer()
        startAccelerometerUpdates()
        startGyroUpdates()
        
        
    }
    func stopMotionUpdates() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        timer?.cancel()
        timer = nil
        isOver = true
        // TODO: save the data in persistence
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
                
            let result = Int(angels.pitch + 90) % 360
            let elapsedTime = Date().timeIntervalSince(self.startTime ?? Date())

            filteredData.append(ChartData(time: Double(elapsedTime), degree: Double(result)))
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
            let result = Int(angels.pitch + 90) % 360
            let elapsedTime = Date().timeIntervalSince(self.startTime ?? Date())
            combinedData.append(ChartData(time: Double(elapsedTime), degree: Double(result)))
        }
    }

    private func startTimer() {
          reset()
          timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
          timer?.schedule(deadline: .now(), repeating: updatedInterval, leeway: .milliseconds(100))
          timer?.setEventHandler { [weak self] in
              guard let self = self else { return }
              if self.timerElapsed() {
                  self.stopMotionUpdates()
                  return
              }
          }
          timer?.resume()
      }

      private func timerElapsed() -> Bool {
          let limit = duration / updatedInterval
          return filteredData.count >= Int(limit)
      }
 

    private func reset() {
        combinedData = []
        filteredData = []
        isOver = false
    }

    deinit {
        stopMotionUpdates()
    }
}
