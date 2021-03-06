//
//  day5.swift
//  aoc2020
//
//  Created by Daniel Nitsikopoulos on 11/12/20.
//

import Foundation

class Day5 {
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "src" }).joined(separator: "/").dropFirst()

    func loadEntries() -> [String] {
        let filePath = "\(packageRootPath)/src/day_5/input.txt"

        let content = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard var lines : [String] = content?.components(separatedBy: "\n") else { return [] }

        lines = lines.dropLast()

        return lines
    }

    func part1() -> Void {
        let entries = loadEntries()
        let seatIds = entries.map { (path) -> Int in
            let seatPath = SeatingArrangement(path: path)
            return seatPath.seatId()
        }
        print(seatIds.max() ?? 0)
    }

    func part2() -> Void {
        let entries = loadEntries()
        let seatIds = entries.map { (path) -> Int in
            let seatPath = SeatingArrangement(path: path)
            return seatPath.seatId()
        }

        let seatIdsSet = Set(seatIds.sorted())
        let seatRange = Set((seatIds.min() ?? 0)...(seatIds.max() ?? 1))
        print(seatRange.symmetricDifference(seatIdsSet))
    }

    func main() -> Void {
        print("Day 5")
        part1()
        part2()
    }
}

enum Direction {
    case Left
    case Right
    case Forward
    case Back
}

extension Direction {
    init?(dir: Character) {
        if dir == "F" {
            self = .Forward
        } else if dir == "B" {
            self = .Back
        } else if dir == "L" {
            self = .Left
        } else if dir == "R" {
            self = .Right
        } else {
            return nil
        }
    }
}

struct SeatingArrangement {
    var rowPath : [Direction] = []
    var seatPath : [Direction] = []

    init(path: String) {
        rowPath = path[..<String.Index(utf16Offset: 7, in: path)].compactMap { Direction(dir: $0) ?? nil }
        seatPath = path[String.Index(utf16Offset: 7, in: path)..<String.Index(utf16Offset: path.count, in: path)].compactMap { Direction(dir: $0) ?? nil }
    }

    func position(max: Int, directions: [Direction]) -> Int {
        var remainingSpot = 0...max
        directions.forEach { (dir) in
            switch dir {
            case .Forward, .Left:
                remainingSpot = remainingSpot.lowerBound...remainingSpot.upperBound - ((remainingSpot.upperBound - remainingSpot.lowerBound) / 2)
            case .Back, .Right:
                remainingSpot = remainingSpot.upperBound - ((remainingSpot.upperBound - remainingSpot.lowerBound) / 2)...remainingSpot.upperBound
            }
        }
        return remainingSpot.first!
    }

    func seatId() -> Int {
        return (position(max: 128, directions: rowPath) * 8) + position(max: 7, directions: seatPath)
    }
}
