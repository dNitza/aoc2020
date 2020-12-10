//
//  day4.swift
//  aoc2020
//
//  Created by Daniel Nitsikopoulos on 10/12/20.
//

import Foundation

class Day4 {
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "src" }).joined(separator: "/").dropFirst()

    func loadEntries() -> [String] {
        let filePath = "\(packageRootPath)/src/day_4/input.txt"

        let content = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard var lines : [String] = content?.components(separatedBy: "\n\n") else { return [] }

        lines = lines.dropLast()
        lines = lines.map({ (line) -> String in
            line.replacingOccurrences(of: "\n", with: " ")
        })

        return lines
    }

    func part1() -> Void {
        let entries = loadEntries()
        let requiredFields = [
            "byr:",
            "iyr:",
            "eyr:",
            "hgt:",
            "hcl:",
            "ecl:",
            "pid:"
        ]
        let validatedPassports = entries.map { (entry) in
            requiredFields.allSatisfy { (field) -> Bool in
                entry.contains(field)
            }
        }
        print(validatedPassports.filter { $0 }.count)
    }

    func part2() -> Void {
        let entries = loadEntries()
        let fields : [Dictionary<String, String>] = entries.map { (entry) -> Dictionary<String, String> in
            var dict : Dictionary<String, String> = [:]
            entry.components(separatedBy: " ").forEach { (field) in
                let parts = field.components(separatedBy: ":")
                dict[parts[0]] = parts[1]
            }
            return dict
        }

        let documents = fields.compactMap { (dict) -> Document? in
            return try? Document.init(dictionary: dict)
        }

        print(documents.filter({ (document) -> Bool in
            document.isValid()
        }).count)

    }

    func main() -> Void {
        print("Day 4")
        self.part1()
        self.part2()
    }
}


fileprivate struct Document : Codable {
    let birthYear: String?
    let issueYear: String?
    let expYear: String?
    let height: String?
    let hairColor: String?
    let eyeColor: String?
    let passportID: String?
    let countryID: String?

    init(dictionary: [String: String]) throws {
        self = try JSONDecoder().decode(Document.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }

    enum CodingKeys: String, CodingKey {
        case birthYear = "byr"
        case issueYear = "iyr"
        case expYear = "eyr"
        case height = "hgt"
        case hairColor = "hcl"
        case eyeColor = "ecl"
        case passportID = "pid"
        case countryID = "cid"
    }

    func isValid() -> Bool {
        birthYearValid() &&
            issueYearValid() &&
            expYearValid() &&
            heightValid() &&
            hairColorValid() &&
            eyeColorValid() &&
            passportIdValid()
    }

    private func birthYearValid() -> Bool {
        self.birthYear != nil && 1920...2002 ~= Int(self.birthYear ?? "0")!
    }

    private func issueYearValid() -> Bool {
        self.issueYear != nil && 2010...2020 ~= Int(self.issueYear ?? "0")!
    }

    private func expYearValid() -> Bool {
        self.expYear != nil && 2020...2030 ~= Int(self.expYear ?? "0")!
    }

    private func heightValid() -> Bool {
        var heightInRange = false
        let measurement = self.height?.prefix(while: { (char) -> Bool in
            char.isNumber
        })
        let measurementVal = Int(String(measurement ?? "0")) ?? 0
        let unit = String((self.height?.suffix(2)) ?? "")
        if unit == "cm" {
            heightInRange = 150...193 ~= measurementVal
        }
        if unit == "in" {
            heightInRange = 59...76 ~= measurementVal
        }
        return self.height != nil && heightInRange
    }

    private func hairColorValid() -> Bool {
        let pattern = "^#[0-9a-f]{6}$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let valid = ((regex?.firstMatch(in: self.hairColor ?? "", options: [], range: NSRange(location: 0, length: self.hairColor?.utf8.count ?? 0))) != nil)
        return valid
    }

    private func eyeColorValid() -> Bool {
        let validColors = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
        guard let color = self.eyeColor else { return false }
        return validColors.contains(color)
    }

    private func passportIdValid() -> Bool {
        return self.passportID?.count == 9 && ((self.passportID?.allSatisfy({ (char) -> Bool in
            char.isNumber
        })) != nil)
    }
}

