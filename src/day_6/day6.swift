//
//  day6.swift
//  aoc2020
//
//  Created by Daniel Nitsikopoulos on 11/12/20.
//

import Foundation

class Day6 {
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "src" }).joined(separator: "/").dropFirst()

    func loadEntries() -> [String] {
        let filePath = "\(packageRootPath)/src/day_6/input.txt"

        let content = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard var lines : [String] = content?.components(separatedBy: "\n\n") else { return [] }

        lines = lines.dropLast()

        return lines
    }

    func part1() -> Void {
        let entries = loadEntries()
        let positiveAnswers = entries.map { (entry) -> Int in
            Set(entry.replacingOccurrences(of: "\n", with: "").map { String($0) }).count
        }

        print(positiveAnswers.reduce(0, +))
    }

    func part2() -> Void {
        let entries = loadEntries()
        let positiveAnswers = entries.map { (entry) -> Int in
            let answers = entry.components(separatedBy: "\n").map { Set($0) }
            let common = answers.reduce(answers.first ?? Set([])) { (res, next) -> Set<Character> in
                res.intersection(next)
            }

            return common.count
        }

        print(positiveAnswers.reduce(0, +))
    }

    func main() -> Void {
        print("Day 6")
        part1()
        part2()
    }
}
