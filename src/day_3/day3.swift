//
//  day_3.swift
//  aoc2020
//
//  Created by Daniel Nitsikopoulos on 10/12/20.
//

import Foundation

class Day3 {

    struct Slope {
        let down: Int
        let right: Int
    }

    let packageRootPath = URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "src" }).joined(separator: "/").dropFirst()

    var currentPos = 0
    var treesHit = 0
    
    func loadEntries() -> [String] {
        let filePath = "\(packageRootPath)/src/day_3/input.txt"

        let content = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard var lines : [String] = content?.components(separatedBy: "\n") else { return [] }

        lines = lines.dropLast()
        
        return lines
    }

    func part1() -> Void {
        let entries = loadEntries()
        currentPos = 0
        treesHit = 0
        entries.forEach { (entry) in
            if entry[entry.index(entry.startIndex, offsetBy: currentPos)] == "#" {
                treesHit += 1
            }

            if currentPos + 3 >= entry.count {
                currentPos = (currentPos + 3) - entry.count
            } else {
                currentPos += 3
            }
        }

        print(treesHit)
    }

    func part2() -> Void {
        let entries = loadEntries()
        let slopes = [
            Slope(down: 1, right: 1),
            Slope(down: 1, right: 3),
            Slope(down: 1, right: 5),
            Slope(down: 1, right: 7),
            Slope(down: 2, right: 1)
        ]

        let allTrees = slopes.map { (slope) -> Int in
            currentPos = 0
            treesHit = 0
            for (index, entry) in entries.enumerated() {
                if index % slope.down != 0 {
                    continue
                }
                if entry[entry.index(entry.startIndex, offsetBy: currentPos)] == "#" {
                    treesHit += 1
                }

                if currentPos + slope.right >= entry.count {
                    currentPos = (currentPos + slope.right) - entry.count
                } else {
                    currentPos += slope.right
                }
            }

            return treesHit
        }

        let result = allTrees.reduce(1, *)
        print(result)
    }
    
    func main() -> Void {
        print("Day 3")
        self.part1()
        self.part2()
    }
}
