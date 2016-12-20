//
//  Sun.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 08/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation
import SceneKit

class Sun: SCNNode {
    
    convenience init(at distance: Float) {
        self.init()
        
        let light = SCNLight()
        light.type = SCNLight.LightType.directional
        light.intensity = 1000
        
        self.light = light
        position = SCNVector3(x: 0, y: 0, z: distance)
    }
}
