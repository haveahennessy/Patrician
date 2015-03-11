//
//  radix.swift
//  Radon
//
//  Created by Matt Isaacs.
//  Copyright (c) 2015 Matt Isaacs. All rights reserved.
//


public class Terminal<T> {
    let key: String
    let value: T // generic later

    public init(key: String, value: T) {
        self.key = key
        self.value = value
    }
}

public class Edge<T> {
    let label: Character
    let node: Node<T>

    public init(label: Character, node: Node<T>) {
        self.label = label
        self.node = node
    }
}

extension Edge: Equatable { }

public func ==<T>(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
    return lhs.label == rhs.label
}


public class Node<T> {
    var edges: [Edge<T>] = []
    var prefix: String
    var terminal: Terminal<T>? = nil

    public init(edges: [Edge<T>], prefix: String, terminal: Terminal<T>?) {
        self.edges = edges
        self.prefix = prefix
        self.terminal = terminal
    }

    // NOTE: built-in find is O(n). Switch to sorted edges with binary search.
    func nodeByCharacter(char: Character) -> Node? {

        if let idx = find(edges, Edge(label: char, node: Node(edges: [], prefix: "", terminal: nil))) {
            return edges[idx].node
        }
        return nil
    }

    // NOTE: built-in find is O(n). Switch to sorted edges with binary search.

    func addEdge(edge: Edge<T>) {
        edges.append(edge)
        edges.sort {
            return $0.label < $1.label
        }
    }

    func replace(edge: Edge<T>) {
        if let idx = find(edges, edge) {
            edges[idx] = edge
        } else {
            edges.append(edge)
        }
    }

    func removeEdge(label: Character) {
        if let idx = find(edges, Edge(label: label, node: Node(edges: [], prefix: "", terminal: nil))) {
            edges.removeAtIndex(idx)
        }
    }
}


public class RTree<T> {
    let root: Node<T>
    var size: Int

    public var count: Int {
        return self.size
    }

    public init(root: Node<T>) {
        self.root = root
        self.size = 0
    }

    public class func emptyTree() -> Self {
        return self.init(root: Node(edges: [], prefix: "", terminal: nil))
    }


    public func insert(key: String, value: T) {
        var search: [Character] = Array(key)
        var currentNode = self.root
        var parent: Node = self.root


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
            if let nextNode: Node = currentNode.nodeByCharacter(search[0]) {
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

                parent.replace(Edge(label: search[0], node: child))

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
            if let nextNode = currentNode.nodeByCharacter(search.first!) {
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
