//
//  immutableRadix.swift
//  Patrician
//
//  Created by Matt Isaacs.
//  Copyright (c) 2015 Matt Isaacs. All rights reserved.
//


struct Terminal<T> {
    let key: String
    let value: T // generic later

    init(key: String, value: T) {
        self.key = key
        self.value = value
    }
}

class Edge<T> {
    let label: Character
    let node: Node<T>

    init(label: Character, node: Node<T>) {
        self.label = label
        self.node = node
    }
}

class Node<T> {
    let edges: [Edge<T>] = []
    let prefix: String
    let terminal: Terminal<T>? = nil

    init(edges: [Edge<T>], prefix: String, terminal: Terminal<T>?) {
        self.edges = edges
        self.prefix = prefix
        self.terminal = terminal
    }

    // Effective binary search will need to make use of Unsafe
    func recSearch(idx: Int, col: [Edge<T>], label: Character) -> Int? {
        let count = col.count
        let mid = count / 2
        let left = col[0...mid]
        let right = col[mid...count - 1]
        let midEdge = col[mid]

        if label == midEdge.label {
            return mid + idx
        }

        if count == 1 {
            return nil
        }

        if label < midEdge.label {
            return recSearch(0, col: Array(left), label: label)
        } else {
            return recSearch(mid + idx, col: Array(right), label: label)
        }
    }

    func edgeForLabel(char: Character) -> Edge<T>? {
        if let idx = recSearch(0, col: self.edges, label: char) {
            return self.edges[idx]
        }
        return nil
    }

    func addEdge(edge: Edge<T>) -> Node<T> {
        var tmp = edges

        tmp.append(edge)
        tmp.sort {
            return $0.label < $1.label
        }

        return Node(edges: tmp, prefix: self.prefix, terminal: self.terminal)
    }

    func replaceEdge(edge: Edge<T>) -> Node<T> {
        var tmp = self.edges
        if let idx = recSearch(0, col: self.edges, label: edge.label) {
            tmp[idx] = edge
        } else {
            tmp.append(edge)
        }
        return Node(edges: tmp, prefix: self.prefix, terminal: self.terminal)
    }

    func removeEdge(label: Character) -> Node<T> {
        var tmp = self.edges
        if let idx = recSearch(0, col: self.edges, label: label) {
            tmp.removeAtIndex(idx)
            return Node(edges: tmp, prefix: self.prefix, terminal: self.terminal)
        }
        return self
    }

    func setTerminal(terminal: Terminal<T>) -> Node<T> {
        return Node(edges: self.edges, prefix: self.prefix, terminal: terminal)
    }

    func setPrefix(prefix: String) -> Node<T> {
        return Node(edges: self.edges, prefix: prefix, terminal: self.terminal)
    }
}

public class RTree<T> {
    let root: Node<T>
    var size: Int

    public var count: Int {
        return self.size
    }

    init(root: Node<T>) {
        self.root = root
        self.size = 0
    }

    public class func emptyTree() -> Self {
        return self.init(root: Node(edges: [], prefix: "", terminal: nil))
    }

    func insert(search: [Character], currentNode: Node<T>, key: String, value: T) -> Node<T> {
        if search.count == 0 {
            if currentNode.terminal != nil {
                return Node(edges: currentNode.edges,
                    prefix: currentNode.prefix,
                    terminal: Terminal(key: key, value: value))
            }
            return currentNode.setTerminal(Terminal(key: key, value: value))
            self.size++
        }

        let parent = currentNode
        if let nextNode: Node = currentNode.edgeForLabel(search.first!)?.node {
            // Edge exists
            let commonPrefix = nextNode.prefix.commonPrefixWithString(String(search), options: NSStringCompareOptions.LiteralSearch)
            let commonPrefixLength = countElements(commonPrefix)

            if commonPrefixLength == countElements(nextNode.prefix) {
                let interval = commonPrefixLength..<search.count
                insert(Array(search[interval]), currentNode: nextNode, key: key, value: value)
                return
            }

            let child = Node<T>(edges: [], prefix: String(search[0..<commonPrefixLength]), terminal: nil)
            let terminal = Terminal(key: key, value: value)
            let currentPrefix = Array(nextNode.prefix)

            parent.replace(Edge(label: search[0], node: child))

            child.addEdge(Edge(label: currentPrefix[commonPrefixLength], node: nextNode))

            nextNode.prefix = String(currentPrefix[commonPrefixLength..<currentPrefix.count])

            let childPrefix = Array(search[commonPrefixLength..<search.count])

            if childPrefix.isEmpty {
                child.terminal = terminal
                return
            }
            child.addEdge(Edge(label: childPrefix[0],
                node: Node(edges: [],
                    prefix: String(childPrefix),
                    terminal: terminal)))
            return
        } else {
            // Create the edge.
            let terminal = Terminal(key: key, value: value)
            let node = Node(edges: [], prefix: String(search), terminal: terminal)
            let edge = Edge(label: search[0], node: node)

            currentNode.edges.append(edge)
            return
        }
    }


    public func insert(key: String, value: T) {
        var search: [Character] = Array(key)
        var currentNode = self.root
        var parent: Node = self.root

        //insert(search, currentNode: currentNode, key: key, value: value)

        while true {
            if  search.count == 0 {
                if let term = currentNode.terminal {
                    currentNode.terminal = Terminal(key: key, value: value)
                    return
                }
                currentNode.terminal = Terminal(key: key, value: value)
                self.size++
                return
            }

            parent = currentNode
            if let nextNode: Node = currentNode.edgeForLabel(search[0])?.node {
                // Edge exists
                currentNode = nextNode
                let commonPrefix = currentNode.prefix.commonPrefixWithString(String(search), options: NSStringCompareOptions.LiteralSearch)
                let commonPrefixLength = countElements(commonPrefix)

                if commonPrefixLength == countElements(currentNode.prefix) {
                    let interval = commonPrefixLength..<search.count
                    search = Array(search[interval])
                    continue
                }

                let child = Node<T>(edges: [], prefix: String(search[0..<commonPrefixLength]), terminal: nil)
                let terminal = Terminal(key: key, value: value)
                let currentPrefix = Array(currentNode.prefix)

                self.size++

                parent.replaceEdge(Edge(label: search[0], node: child))

                child.addEdge(Edge(label: currentPrefix[commonPrefixLength], node: currentNode))

                currentNode.prefix = String(currentPrefix[commonPrefixLength..<currentPrefix.count])

                search = Array(search[commonPrefixLength..<search.count])

                if search.isEmpty {
                    child.terminal = terminal
                    return
                }
                child.addEdge(Edge(label: search[0],
                    node: Node(edges: [],
                        prefix: String(search),
                        terminal: terminal)))
                return

            } else {
                // Create the edge.
                let terminal = Terminal(key: key, value: value)
                let node = Node(edges: [], prefix: String(search), terminal: terminal)
                let edge = Edge(label: search[0], node: node)

                currentNode.addEdge(edge)
                self.size++
                return
            }
        }
    }

    public func lookup(key: String) -> T? {
        var search = Array(key)
        var currentNode = self.root

        while true {
            if  search.count == 0 {
                if let term = currentNode.terminal {
                    return term.value
                }
                return nil
            }

            // search.first can be unwrapped, because we know know that it is non-nil from the check above.
            if let nextNode = currentNode.edgeForLabel(search.first!)?.node {
                currentNode = nextNode

                let currentPrefixLength = countElements(currentNode.prefix)

                let searchString = String(search)
                if searchString.hasPrefix(currentNode.prefix) {
                    search = Array(search[currentPrefixLength..<search.count])
                    continue
                }
            }
            return nil
        }
    }

    public func delete(key: String) {
        var search = Array(key)
        var currentNode = self.root
        var parent = self.root

        if search.count == 0 {
            return
        }

        while true {
            // Locate value to be deleted
            if search.count == 0 {
                if let term = currentNode.terminal {
                    // Remove leaf
                    currentNode.terminal = nil
                    size--
                    if currentNode.edges.count == 0 {
                        let prefixArray = Array(currentNode.prefix)
                        if let label = prefixArray.first {
                            parent.removeEdge(label)

                            // The parent only has one edge remaining.
                            // The parent has no leaf value.
                            // The parent isn't the tree root.
                            if (parent.edges.count == 1) && (countElements(parent.prefix) != 0) && (parent.terminal == nil) {
                                let child = parent.edges.first!.node
                                parent.prefix += child.prefix
                                parent.edges = child.edges
                                parent.terminal = child.terminal
                            }
                        }
                        return
                    }

                    if currentNode.edges.count == 1 {
                        let child = currentNode.edges.first!.node
                        currentNode.prefix += child.prefix
                        currentNode.edges = child.edges
                        currentNode.terminal = child.terminal
                    }
                }
                return
            }

            parent = currentNode
            // search.first can be unwrapped, because we know know that it is non-nil from the check above.
            if let nextNode = currentNode.nodeByCharacter(search.first!) {
                currentNode = nextNode
                
                let currentPrefixLength = countElements(currentNode.prefix)
                
                let searchString = String(search)
                if searchString.hasPrefix(currentNode.prefix) {
                    search = Array(search[currentPrefixLength..<search.count])
                    continue
                }
            }
            return
        }
    }
}

