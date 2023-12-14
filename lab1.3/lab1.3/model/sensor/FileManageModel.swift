//
//  FileManageModel.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-14.
//

import Foundation

class FileManageModel {
    
    func saveCSV(chartDataArray: [ChartData]) {
        // Convert ChartData to CSV String
        let csvString = chartDataArray.map { data -> String in
            "\(data.time),\(data.degree)"  // Using time as Unix timestamp
        }.joined(separator: "\n")
        
        let csvHeader = "Time,Degree\n" + csvString  // Adding header

        // Getting the document directory path
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Set the desired format
        let filename = dateFormatter.string(from: Date())
        let fileURL = paths[0].appendingPathComponent(filename)

        do {
            // Writing to the file
            try csvHeader.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV file saved: \(fileURL)")
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    
    func listFilesFromDocumentsFolder() -> [String] {
        let fileManager = FileManager.default

        // Get the URL for the documents directory
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found")
            return []
        }

        do {
            // Get the list of file URLs in the documents directory
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)

            // Convert the URLs to String (file names)
            return fileURLs.map { $0.lastPathComponent }
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
            return []
        }
    }
    
    func readChartData(_ fileName: String) -> [ChartData] {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found")
            return []
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = contents.components(separatedBy: "\n")
            return rows.compactMap { row -> ChartData? in
                let columns = row.components(separatedBy: ",")
                print(columns[0])
                print(columns[1])
                guard columns.count == 2,
                      let time = Double(columns[0]),
                      let degree = Double(columns[1]) else {
                    return nil
                }
                return ChartData(time: time, degree: degree)
            }
        } catch {
            print("Error reading file: \(error)")
            return []
        }
    }
    
}
