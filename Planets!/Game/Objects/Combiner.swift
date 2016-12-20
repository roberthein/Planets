//
//  Combiner.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 08/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation

enum Combiner: Int {
    case add
    case divide
    case multiply
    case power
    case subtract
    
    private static let count: Combiner.RawValue = {
        var maxValue: Int = 0
        while let _ = Combiner(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()
    
    static func random() -> Combiner {
        let combiner = Combiner(rawValue: Int.random(count))!
        combiner.log()
        return combiner
    }
    
    func object() -> AHNCombiner {
        switch self {
        case .add: return AHNCombinerAdd()
        case .divide: return AHNCombinerDivide()
        case .multiply: return AHNCombinerMultiply()
        case .power: return AHNCombinerPower()
        case .subtract: return AHNCombinerSubtract()
        }
    }
    
    func log() {
        print("combiner:\(self)")
    }
}
