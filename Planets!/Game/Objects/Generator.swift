//
//  Generator.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 08/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation

enum Generator: Int {
    case billow
    case ridgedMulti
    case simplex
    
    private static let count: Generator.RawValue = {
        var maxValue: Int = 0
        while let _ = Generator(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()
    
    static func random() -> Generator {
        let generator = Generator(rawValue: Int.random(count))!
        generator.log()
        return generator
    }
    
    func object() -> AHNGeneratorCoherent {
        switch self {
        case .billow: return AHNGeneratorBillow()
        case .ridgedMulti: return AHNGeneratorRidgedMulti()
        case .simplex: return AHNGeneratorSimplex()
        }
    }
    
    func log() {
        print("generator:\(self)")
    }
}
