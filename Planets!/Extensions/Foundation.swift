//
//  Foundation.swift
//  demo
//
//  Created by Robert-Hein Hooijmans on 08/11/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation

extension Float {
    
    static func random() -> Float {
        return Float(arc4random() % 1000) / 1000
    }
}

extension Int {
    
    static func random(_ max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    static func random(lower: Int , upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
}

func lerp(from a: Float, to b: Float, alpha: Float) -> Float {
    return (1 - alpha) * a + alpha * b
}
