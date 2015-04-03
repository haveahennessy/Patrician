//
//  RadonTests.swift
//  RadonTests
//
//  Created by Matt Isaacs.
//  Copyright (c) 2015 Matt Isaacs. All rights reserved.
//

import Radon
import XCTest

class RadonTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInsert() {
        var tree: RadixTree<Int> = RadixTree.emptyTree()
        tree.insert("wolf", value: 3)
        tree.insert("world", value: 2)
        tree.insert("bear", value: 1)
        tree.insert("wacker", value: 5)

        let wacker = tree["wacker"]
        let wolf = tree["wolf"]
        let world = tree["world"]
        let bear = tree["bear"]

        XCTAssert(bear == 1, "Lookup failed.")
        XCTAssert(world == 2, "Lookup failed.")
        XCTAssert(wolf == 3, "Lookup failed.")
        XCTAssert(wacker == 5, "Lookup failed.")
        XCTAssert(tree.count == 4, "Size mismatch.")
    }

    func testDeleteSizeOne() {
        var tree: RadixTree<Int> = RadixTree.emptyTree()
        tree.insert("wolf", value: 3)
        XCTAssert(tree.count == 1, "Size mismatch.")
        tree.delete("w")
        XCTAssert(tree["wolf"] == 3, "Missing value.")
        XCTAssert(tree.count == 1, "Size mismatch.")
        tree.delete("wolf")
        XCTAssertNil(tree["wolf"], "Delete failed.")
        XCTAssert(tree.count == 0, "Size mismatch.")
    }

    func testDelete() {
        var tree: RadixTree<Int> = RadixTree.emptyTree()
        tree.insert("wolf", value: 3)
        tree.insert("world", value: 2)
        XCTAssert(tree.count == 2, "Size mismatch.")
        tree.delete("w")
        XCTAssert(tree.count == 2, "Size mismatch.")
        tree.delete("wolf")
        XCTAssert(tree["world"] == 2, "Missing value.")
        XCTAssertNil(tree["wolf"], "Delete failed.")
        XCTAssert(tree.count == 1, "Size mismatch.")
    }
    
    func testPerformanceExample() {
        self.measureBlock() {

        }
    }
    
}
