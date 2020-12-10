//
//  day_3.swift
//  aoc2020
//
//  Created by Daniel Nitsikopoulos on 10/12/20.
//

import Foundation

class Day3 {
    
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "src" }).joined(separator: "/").dropFirst()
    
    func loadEntries() -> [Int] {
        let filePath = "\(packageRootPath)/src/day_3/input.txt"

        let content = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard let lines : [String] = content?.components(separatedBy: "\n") else { return [] }
        
        return lines.compactMap { (line) -> Int? in
            Int(line)
        }
    }
    
    
    func main() -> Void {
        
    }
}
