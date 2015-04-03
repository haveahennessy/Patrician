//
//  radix.swift
//  Patrician
//
//  Created by Matt Isaacs.
//  Copyright (c) 2015 Matt Isaacs. All rights reserved.
//

struct Terminal<T> {
    let key: String
    let value: T

    init(key: String, value: T) {
        self.key = key
        self.value = value
    }
}

struct Edge<T> {
    let label: Character
    let node: Node<T>

    init(label: Character, node: Node<T>) {
        self.label = label
        self.node = node
    }
}

public struct RadixTree<T> {
    let root: Node<T>
    var size: Int

    public var count: Int {
        return self.size
    }

    init(root: Node<T>) {
        self.root = root
        self.size = 0
    }

    public init() {
        self.init(root: Node(edges: [], prefix: "", terminal: nil))
    }

    public static func emptyTree() -> RadixTree {
        return self.init(root: Node(edges: [], prefix: "", terminal: nil))
    }

    // Item insertion
    public mutating func insert(key: String, value: T) {
        //var search: [Character] = Array(key)
        var search = key
        var currentNode = self.root
        var parent = self.root

        while true {
            if search.endIndex == search.startIndex {
                if let term = currentNode.terminal {
                    currentNode.terminal = Terminal(key: key, value: value)
                    return
                }
                currentNode.terminal = Terminal(key: key, value: value)
                self.size++
                return
            }

            //let searchLabel = search[0]
            let searchLabel = search.first!

            parent = currentNode

            if let nextNode = currentNode.edgeForLabel(searchLabel)?.node {
                // Edge exists
                currentNode = nextNode
                let commonPrefix = currentNode.prefix.commonPrefixWithString(search, options: NSStringCompareOptions.LiteralSearch)
                let commonPrefixLength = commonPrefix.endIndex

                search = search.substringFromIndex(commonPrefixLength)
                if commonPrefixLength == currentNode.prefix.endIndex {
                    continue
                }

                let intermediate = Node<T>(edges: [], prefix: commonPrefix, terminal: nil)
                let terminal = Terminal(key: key, value: value)
                let currentSuffix = currentNode.prefix.substringFromIndex(commonPrefixLength)

                self.size++

                parent.replaceEdge(Edge(label: searchLabel, node: intermediate))
                intermediate.addEdge(Edge(label: currentSuffix[currentSuffix.startIndex], node: currentNode))
                currentNode.prefix = currentSuffix

                if search.isEmpty {
                    intermediate.terminal = terminal
                } else {
                    intermediate.addEdge(Edge(label: search.first!,
                        node: Node(edges: [],
                            prefix: search,
                            terminal: terminal)))
                }
                return

            } else {
                // Create the edge.
                let terminal = Terminal(key: key, value: value)
                let node = Node(edges: [], prefix: search, terminal: terminal)
                let edge = Edge(label: searchLabel, node: node)

                currentNode.addEdge(edge)
                self.size++
                return
            }
        }
    }

    // Item lookup by key.
    public func lookup(key: String) -> T? {
        var search = key
        var currentNode = self.root

        while true {
            if  search.endIndex == search.startIndex {
                if let term = currentNode.terminal {
                    return term.value
                }
                return nil
            }

            // search.first can be unwrapped, because we know know that it is non-nil from the check above.
            if let nextNode = currentNode.edgeForLabel(search.first!)?.node {
                currentNode = nextNode

                let currentPrefixLength = currentNode.prefix.endIndex

                if search.hasPrefix(currentNode.prefix) {
                    search = search.substringFromIndex(currentPrefixLength)
                    continue
                }
            }
            return nil
        }
    }

    // Remove items from tree.
    public mutating func delete(key: String) {
        var search = key
        var currentNode = self.root
        var parent = self.root

        if search.endIndex == search.startIndex {
            return
        }

        while true {
            // Locate value to be deleted
            if search.endIndex == search.startIndex {
                if let term = currentNode.terminal {
                    // Remove leaf
                    currentNode.terminal = nil
                    size--
                    if currentNode.edges.count == 0 {
                        //let prefixArray = Array(currentNode.prefix)
                        if let label = currentNode.prefix.first {
                            parent.removeEdge(label)

                            // The parent only has one edge remaining.
                            // The parent has no leaf value. 
                            // The parent isn't the tree root.
                            if (parent.edges.count == 1) && (parent.prefix.endIndex != parent.prefix.startIndex) && (parent.terminal == nil) {
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
            if let nextNode = currentNode.edgeForLabel(search.first!)?.node {
                currentNode = nextNode

                let currentPrefixLength = currentNode.prefix.endIndex

                if search.hasPrefix(currentNode.prefix) {
                    search = search.substringFromIndex(currentPrefixLength)
                    continue
                }
            }
            return
        }
    }

    public subscript(key: String) -> T? {
        get {
            return self.lookup(key)
        }

        set(newValue) {
            if let val = newValue {
                self.insert(key, value: val)
            }
        }
    }
}
