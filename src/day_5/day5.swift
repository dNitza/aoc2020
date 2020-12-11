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

enum RowDirection {
    case Forward
    case Back
}

enum SeatDirection {
    case Left
    case Right
}

extension RowDirection {
    init?(dir: Character) {
        if dir == "F" {
            self = .Forward
        } else if dir == "B" {
            self = .Back
        } else {
            return nil
        }
    }
}

extension SeatDirection {
    init?(dir: Character) {
        if dir == "L" {
            self = .Left
        } else if dir == "R" {
            self = .Right
        } else {
            return nil
        }
    }
}

struct SeatingArrangement {
    var rowPath : [RowDirection] = []
    var seatPath : [SeatDirection] = []
    let rows = 128
    let seats = 7

    init(path: String) {
        rowPath = path[..<String.Index(utf16Offset: 7, in: path)].compactMap { RowDirection(dir: $0) ?? nil }
        seatPath = path[String.Index(utf16Offset: 7, in: path)..<String.Index(utf16Offset: path.count, in: path)].compactMap { SeatDirection(dir: $0) ?? nil }
    }

    func rowNumber() -> Int {
        var remainingRows = 0...rows
        rowPath.forEach { (dir) in
            switch dir {
            case .Forward:
                remainingRows = remainingRows.lowerBound...remainingRows.upperBound - ((remainingRows.upperBound - remainingRows.lowerBound) / 2)
            case .Back:
                remainingRows = remainingRows.upperBound - ((remainingRows.upperBound - remainingRows.lowerBound) / 2)...remainingRows.upperBound
            }
        }
        return remainingRows.first!
    }

    func seatNumber() -> Int {
        var remainingSeats = 0...seats
        seatPath.forEach { (dir) in
            switch dir {
            case .Left:
                remainingSeats = remainingSeats.lowerBound...remainingSeats.upperBound - ((remainingSeats.upperBound - remainingSeats.lowerBound) / 2)
            case .Right:
                remainingSeats = remainingSeats.upperBound - ((remainingSeats.upperBound - remainingSeats.lowerBound) / 2)...remainingSeats.upperBound
            }
        }
        return remainingSeats.first!
    }

    func seatId() -> Int {
        return (rowNumber() * 8) + seatNumber()
    }
}
