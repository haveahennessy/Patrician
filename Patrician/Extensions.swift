//
//  Extensions.swift
//  Patrician
//
//  Created by Matt Isaacs.
//  Copyright (c) 2015 Matt Isaacs. All rights reserved.
//

extension String {
    var first: Character? {
        if countElements(self) > 0 {
            return self[self.startIndex]
        }
        return nil
    }
}

extension ContiguousArray {
    var slice: Slice<T> {
        return self[0..<self.endIndex]
    }
}
