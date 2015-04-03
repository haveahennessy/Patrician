//
//  Node.swift
//  Patrician
//
//  Created by Matt Isaacs.
//  Copyright (c) 2015 Matt Isaacs. All rights reserved.
//

class Node<T> {
    var edges: ContiguousArray<Edge<T>> = []
    var prefix: String
    var terminal: Terminal<T>? = nil

    init(edges: ContiguousArray<Edge<T>>, prefix: String, terminal: Terminal<T>?) {
        self.edges = edges
        self.prefix = prefix
        self.terminal = terminal
    }

    convenience init(edges: ContiguousArray<Edge<T>>, prefix: Array<Character>, terminal: Terminal<T>?) {
        self.init(edges: edges, prefix: String(prefix), terminal: terminal)
    }

    func search(idx: Int, col: Slice<Edge<T>>, label: Character) -> Int? {
        let count = col.count
        if count == 1 {
            return label == col[0].label ? idx : nil
        }
        if count > 1 {

            let mid = count / 2
            let left = col[0..<mid]
            let right = col[mid..<count]
            let midEdge = col[mid]

            if label == midEdge.label {
                return mid + idx
            }

            if label < midEdge.label {
                return search(0, col: left, label: label)
            } else {
                return search(mid + idx, col: right, label: label)
            }
        }

        return nil
    }

    func edgeForLabel(char: Character) -> Edge<T>? {
        if let idx = search(0, col: self.edges.slice, label: char) {
            return self.edges[idx]
        }
        return nil
    }

    func addEdge(edge: Edge<T>) {
        self.edges.append(edge)
        self.edges.sort {
            return $0.label < $1.label
        }
    }

    func replaceEdge(edge: Edge<T>) {
        if let idx = search(0, col: self.edges.slice, label: edge.label) {
            self.edges[idx] = edge
        } else {
            self.edges.append(edge)
        }
    }

    func removeEdge(label: Character) {
        if let idx = search(0, col: self.edges.slice, label: label) {
            self.edges.removeAtIndex(idx)
        }
    }

    func setTerminal(terminal: Terminal<T>) {
        self.terminal = terminal
    }

    func setPrefix(prefix: String) {
        self.prefix = prefix
    }

    func setPrefix(prefix: Array<Character>) {
        self.prefix = String(prefix)
    }
}
