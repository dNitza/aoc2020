//
//  main.swift
//  aoc2020
//
//  Created by Daniel Nitsikopoulos on 10/12/20.
//

import Foundation

class Day1 {
    let target = 2020

    let packageRootPath = URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "src" }).joined(separator: "/").dropFirst()
    
    func loadEntries() -> [Int] {
        let filePath = "\(packageRootPath)/src/day_1/input.txt"

        let content = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard let lines : [String] = content?.components(separatedBy: "\n") else { return [] }
        
        return lines.compactMap { (line) -> Int? in
            Int(line)
        }
    }

    func part1() -> Void {
        let entries = loadEntries()
        if let ele = entries.first(where: { (entry) -> Bool in
            let v = target - entry
            return entries.contains(v)
        }) {
            print(ele * (target - ele))
        }
    }

    func part2() -> Void {
        let entries = loadEntries()
        entries.forEach { (x) in
            entries.forEach { (y) in
                entries.forEach { (z) in
                    if x + y + z == target {
                        print(x * y * z)
                    }
                }
            }
        }
    }
    
    
    func main() -> Void{
        print("Day 1")
        self.part1()
        self.part2()
    }
}

//Day1().main()
