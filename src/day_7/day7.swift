//
//  day7.swift
//  aoc2020
//
//  Created by Daniel Nitsikopoulos on 13/12/20.
//

import Foundation

class Day7 {
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents
        .prefix(while: { $0 != "src" }).joined(separator: "/").dropFirst()

    func loadEntries() -> [String] {
        let filePath = "\(packageRootPath)/src/day_7/input.txt"

        let content = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard var lines : [String] = content?.components(separatedBy: "\n") else { return [] }

        lines = lines.dropLast()

        return lines
    }

    func part1() -> Void {
        let graph = buildGraph()
        let paths = graph.vertices.compactMap { (vert) -> Int? in
            if let index = graph.indexOfVertex(vert) {
                let path = graph.dfs(fromIndex: index) { (vert) -> Bool in
                    vert == "shiny gold"
                }
                return path.count
            }

            return 0
        }

        print(paths.filter({ (pathsCount) -> Bool in
            pathsCount >= 1
        }).count)
    }

    func part2() -> Void {
    }

    func main() -> Void {
        print("Day 7")
        part1()
        part2()
    }

    func buildGraph() -> BagGraph<String>{
        let entries = loadEntries()
        let rules = entries.compactMap { (entry) -> Rule? in
            if let rule = parseRule(ruleDescription: entry) {
                return rule
            }

            return nil
        }

        var graph = BagGraph(vertices: rules.map({ (rule) -> String in
            rule.container
        }))

        rules.forEach { (rule) in
            rule.contents.forEach { (content) in
                graph.addEdge(from: rule.container, to: content)
            }
        }

        return graph
    }
}

func parseRule(ruleDescription: String) -> Rule? {
    var containerName: String?
    var contents: [String]?

    let containerPattern = "^(\\w*\\s\\w*) bags contain"
    let contentsPattern = "(\\d)\\s(\\w*\\s\\w*)"
    let containerRegex = try? NSRegularExpression(pattern: containerPattern, options: .caseInsensitive)
    if let match = containerRegex?.firstMatch(in: ruleDescription, options: [], range: NSRange(location: 0, length: ruleDescription.utf8.count)) {
        if let containerNameMatch = Range(match.range(at: 1), in: ruleDescription) {
            containerName = String(ruleDescription[containerNameMatch])
        }
    }

    let contentsRegex = try? NSRegularExpression(pattern: contentsPattern, options: .caseInsensitive)
    if let matches = contentsRegex?.matches(in: ruleDescription, options: [], range: NSRange(location: 0, length: ruleDescription.utf8.count)) {

        contents = matches.compactMap { (match) -> String? in
            if let contentsMatch = Range(match.range(at: 2), in: ruleDescription) {
                return String(ruleDescription[contentsMatch])
            }

            return nil
        }
    }

    if let containerName = containerName, let contents = contents {
        return Rule(container: containerName, contents: contents)
    }
    
    return nil
}

struct Rule {
    let container: String
    let contents: [String]
}

protocol Edge: CustomStringConvertible & Codable {
    var u: Int {get set}
    var v: Int {get set}
    func reversed() -> Self
}

protocol Graph: CustomStringConvertible, Collection, Codable {
    associatedtype V: Equatable & Codable
    associatedtype E: Edge & Equatable
    var vertices: [V] {get set}
    var edges: [[E]] {get set}

    init(vertices: [V])
    func addEdge(_ e: E)
 }

extension Graph {
    mutating func addEdge(e: E) {
        edges[e.u].append(e)
//        if e.u != e.v {
//            edges[e.v].append(e.reversed())
//        }
    }

    func edgesForVertex(_ vertex: V) -> [E]? {
        if let index = indexOfVertex(vertex) {
            return edgesForIndex(index)
        }

        return  nil
    }

    func indexOfVertex(_ vertex: V) -> Int? {
        if let index = vertices.firstIndex(of: vertex) {
            return index
        }

        return nil
    }

    func edgesForIndex(_ index: Int) -> [E] {
        return edges[index]
    }

    func vertexAtIndex(_ index: Int) -> V {
        return vertices[index]
    }

    func vertexCount() -> Int {
        return vertices.count
    }

    mutating func addVertex(_ v: V) -> Int {
        vertices.append(v)
        edges.append([E]())
        return self.vertices.count - 1
    }

    func neighborsForIndex(_ index: Int) -> [V] {
        return edges[index].map({self.vertices[$0.v]})
    }

    func neighborsForVertex(_ vertex: V) -> [V]? {
        if let i = indexOfVertex(vertex) {
            return neighborsForIndex(i)
        }
        return nil
    }

    // Protocol conformation
    // Printable
    var description: String {
        var d: String = ""
        for i in 0..<vertices.count {
            d += "\(vertices[i]) -> \(neighborsForIndex(i))\n"
        }
        return d
    }

    // Collections

    var startIndex: Int {
        return 0
    }

    var endIndex: Int {
        return vertexCount()
    }

    func index(after i: Int) -> Int {
        return i + 1
    }

    subscript(i: Int) -> V {
        return vertexAtIndex(i)
    }
}

extension Graph {
    func dfs(fromIndex: Int, goalTest: (V) -> Bool) -> [E] {
        // pretty standard dfs that doesn't visit anywhere twice; pathDict tracks route
        var visited: [Bool] = [Bool](repeating: false, count: vertexCount())
        var stack: Array<Int> = Array<Int>()
        var pathDict: [Int: E] = [Int: E]()
        stack.append(fromIndex)
        while !stack.isEmpty {
            let v: Int = stack.removeLast()
            if (visited[v]) {
                continue
            }
            visited[v] = true
            if goalTest(vertexAtIndex(v)) {
                // figure out route of edges based on pathDict
                return pathDictToPath(from: fromIndex, to: v, pathDict: pathDict) as! [Self.E]
            }
            for e in edgesForIndex(v) {
                if !visited[e.v] {
                    stack.append(e.v)
                    pathDict[e.v] = e
                }
            }
        }
        return [] // no route found
    }

    public func pathDictToPath(from: Int, to: Int, pathDict:[Int:Edge]) -> [Edge] {
        if pathDict.count == 0 || from == to {
            return []
        }
        var edgePath: [Edge] = [Edge]()
        var e: Edge = pathDict[to]!
        edgePath.append(e)
        while (e.u != from) {
            e = pathDict[e.u]!
            edgePath.append(e)
        }
        return Array(edgePath.reversed())
    }
}

class BagGraph<V: Equatable & Codable>: Graph {

//    var description: String {
//        return ""
//    }

    var vertices: [V] = [V]()
    var edges: [[BagEdge]] = [[BagEdge]]()

    init() {
    }

    required init(vertices: [V]) {
        for vertex in vertices {
            _ = self.addVertex(vertex)
        }
    }

    func addEdge(_ e: BagEdge) {
        edges[e.u].append(e)
//        if e.u != e.v {
//            edges[e.v].append(e.reversed())
//        }
    }

    func addVertex(_ v: V) -> Int {
        vertices.append(v)
        edges.append([E]())
        return vertices.count - 1
    }
}

struct BagEdge: Edge, CustomStringConvertible, Equatable, BagEdgeProtocol {
    func reversed() -> BagEdge {
        return BagEdge(u: v, v: u)
    }

    var u: Int
    var v: Int

    init(u: Int, v: Int) {
        self.u = u
        self.v = v
    }

    var description: String {
        return "\(u) -> \(v)"
    }

    static func ==(lhs: BagEdge, rhs: BagEdge) -> Bool {
        return lhs.u == rhs.u && lhs.v == rhs.v
    }

}

extension Graph where E: BagEdgeProtocol {
    mutating func addEdge(fromIndex: Int, toIndex: Int) {
        addEdge(e: E(u: fromIndex, v: toIndex))
    }

    mutating func addEdge(from: V, to: V) {
        if let u = indexOfVertex(from), let v = indexOfVertex(to) {
            addEdge(fromIndex: u, toIndex: v)
        }
    }
}

protocol BagEdgeProtocol {
    init(u: Int, v: Int)
}
