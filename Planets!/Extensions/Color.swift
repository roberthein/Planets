//
//  Color.swift
//  demo
//
//  Created by Robert-Hein Hooijmans on 18/11/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (r, g, b, a)
    }
    
    func combine(with color: UIColor, amount: CGFloat) -> UIColor {
        let fromComponents = components()
        let toComponents = color.components()
        
        let r = CGFloat(lerp(from: Float(fromComponents.red), to: Float(toComponents.red), alpha: Float(amount)))
        let g = CGFloat(lerp(from: Float(fromComponents.green), to: Float(toComponents.green), alpha: Float(amount)))
        let b = CGFloat(lerp(from: Float(fromComponents.blue), to: Float(toComponents.blue), alpha: Float(amount)))
        
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static func random() -> UIColor {
        return UIColor(red: CGFloat(Float.random()), green: CGFloat(Float.random()), blue: CGFloat(Float.random()), alpha: 1)
    }
    
    func red() -> CGFloat {
        var red: CGFloat = 0
        getRed(&red, green: nil, blue: nil, alpha: nil)
        return red
    }
    
    func green() -> CGFloat {
        var green: CGFloat = 0
        getRed(nil, green: &green, blue: nil, alpha: nil)
        return green
    }
    
    func blue() -> CGFloat {
        var blue: CGFloat = 0
        getRed(nil, green: nil, blue: &blue, alpha: nil)
        return blue
    }
}
