//
//  FileManageModel.swift
//  lab1.3
//
//  Created by Hamada Aljarrah on 2023-12-14.
//

import Foundation

class FileManageModel {
    
    func saveCSV(filteredData: [ChartData], combinedData: [ChartData]) {
        // Convert first ChartData array to CSV String
        let filteredDataCSV = filteredData.map { "\( $0.time),\( $0.degree)" }.joined(separator: "\n")
        
        // Convert second ChartData array to CSV String
        let combinedDataCSV = combinedData.map { "\( $0.time),\( $0.degree)" }.joined(separator: "\n")
        
        let csvHeader = "Time,Degree"
        let completeCsvString = "\(csvHeader)\n\(filteredDataCSV)\n#SECOND_ARRAY\n\(csvHeader)\n\(combinedDataCSV)"

        // Getting the document directory path
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Set the desired format
        let filename = dateFormatter.string(from: Date())
        let fileURL = paths[0].appendingPathComponent(filename)

        do {
            // Writing the complete CSV string to the file
            try completeCsvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV file saved: \(fileURL)")
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
   
    
    func readFilteredChartDataArray(_ fileName: String) -> [ChartData] {
        return readChartDataArray(fileName,  0)
    }

    func readCombinedChartDataArray(_ fileName: String) -> [ChartData] {
        return readChartDataArray(fileName,  1)
    }
    
    private func readChartDataArray(_ fileName: String, _ arrayIndex: Int) -> [ChartData] {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found")
            return []
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            let sections = contents.components(separatedBy: "#SECOND_ARRAY\n")
            guard arrayIndex < sections.count else {
                print("Invalid array index")
                return []
            }

            let rows = sections[arrayIndex].components(separatedBy: "\n")
            // Skip the header if it's not the first section
            let dataRows = arrayIndex == 0 ? rows : Array(rows.dropFirst())

            return dataRows.compactMap { row -> ChartData? in
                let columns = row.components(separatedBy: ",")
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
    
}
