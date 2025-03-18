//
//  MapLoader.swift
//  Overrun
//
//  Created by Samuel Chow on 2025-03-18.
//

import Foundation

func LoadMap(from filename: String) -> [[Int]]?
{
    guard let path = Bundle.main.path(forResource: filename, ofType: "txt") else {
        print("File not found: \(filename)")
        return nil
    }
    
    do {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        let rows = content.split(separator: "\r\n")
        
        //print(rows)
            
        let Array2D = rows.filter{!$0.isEmpty}                      // remove the empty row
                            .map { row in
                                    row.split(separator: " ")       // each row split by space to get each column val
                                        .compactMap { Int($0) }     // skip the non Integer number
        }
        return Array2D
    } catch {
        print("Error reading file: \(error)")
        return nil
    }
}
