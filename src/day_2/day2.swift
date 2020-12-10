//
//  main.swift
//  aoc2020
//
//  Created by Daniel Nitsikopoulos on 10/12/20.
//

import Foundation

class Day2 {
    struct PasswordEntry {
        let policy: (ClosedRange<Int>, Character)
        let password: String
    }
    
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "src" }).joined(separator: "/").dropFirst()
    
    func loadEntries() -> [PasswordEntry] {
        let filePath = "\(packageRootPath)/src/day_2/input.txt"

        let content = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard let lines : [String] = content?.components(separatedBy: "\n") else { return [] }
        
        // line: 4-8 n: dnjjrtclnzdnghnbnn
        let passwordEntryPattern = "^(\\d{1,2})-(\\d{1,2})\\s([a-z])[:]\\s([a-z]*)$"
        let passwordEntryRegex = try? NSRegularExpression(pattern: passwordEntryPattern, options: .caseInsensitive)
        
        return lines.compactMap { (line) -> PasswordEntry? in
            guard line != "" else { return nil }
            if let match = passwordEntryRegex?.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf8.count)) {
                
                var rangeStart: Int?
                var rangeEnd: Int?
                var letter: Character?
                var password: String?
                
                if let rangeStartMatch = Range(match.range(at: 1), in: line) {
                    rangeStart = Int(line[rangeStartMatch])
                }
                
                if let rangeEndMatch = Range(match.range(at: 2), in: line) {
                    rangeEnd = Int(line[rangeEndMatch])
                }
                
                if let letterMatch = Range(match.range(at: 3), in: line) {
                    letter = Character(String(line[letterMatch]))
                }
                
                if let passwordMatch = Range(match.range(at: 4), in: line) {
                    password = String(line[passwordMatch])
                }
                    
                let closedRange = rangeStart!...rangeEnd!
                return PasswordEntry(policy: (closedRange, letter!), password: password!)
            }
            
            return nil
        }
    }

    func part1() -> Void {
        let entries = loadEntries()
        
        let results = entries.filter { (entry) -> Bool in
            let keyLetter = entry.policy.1
            let occurences = entry.password.components(separatedBy: String(keyLetter)).count - 1
            return entry.policy.0 ~= occurences
        }
        print(results.count)
    }
    
    func part2() -> Void {
        let entries = loadEntries()
        
        let results = entries.filter { (entry) -> Bool in
            let keyLetter = entry.policy.1
            let startIndex = entry.policy.0.lowerBound - 1
            let endIndex = entry.policy.0.upperBound - 1
            return (entry.password[entry.password.index(entry.password.startIndex, offsetBy: startIndex)] == keyLetter) ^ (entry.password[entry.password.index(entry.password.startIndex, offsetBy: endIndex)] == keyLetter)
        }
        print(results.count)
    }
    
    func main() -> Void {
        print("Day 2")
        self.part1()
        self.part2()
    }
}

fileprivate extension Bool {
    static func ^ (lhs: Bool, rhs: Bool) -> Bool {
        return lhs != rhs
    }
}
