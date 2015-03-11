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
        let tree: RTree<Int> = RTree.emptyTree()
        tree.insert("wolf", value: 3)
        tree.insert("world", value: 2)
        tree.insert("wacko", value: 1)
        tree.insert("wacker", value: 5)

        let wacker = tree.lookup("wacker")
        XCTAssert(tree.count == 4, "Size mismatch.")
    }

    func testDeleteSizeOne() {
        let tree: RTree<Int> = RTree.emptyTree()
        tree.insert("wolf", value: 3)
        XCTAssert(tree.count == 1, "Size mismatch.")
        tree.delete("w")
        XCTAssert(tree.count == 1, "Size mismatch.")
        tree.delete("wolf")
        XCTAssert(tree.count == 0, "Size mismatch.")
    }

    //Broken
    func testDelete() {
        let tree: RTree<Int> = RTree.emptyTree()
        tree.insert("wolf", value: 3)
        tree.insert("world", value: 2)
        XCTAssert(tree.count == 2, "Size mismatch.")
        tree.delete("w")
        XCTAssert(tree.count == 2, "Size mismatch.")
        tree.delete("wolf")
        XCTAssert(tree.count == 1, "Size mismatch.")
    }
    
    func testPerformanceExample() {
        self.measureBlock() {

        }
    }
    
}
