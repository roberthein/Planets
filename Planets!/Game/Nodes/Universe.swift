//
//  Universe.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 08/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation
import SceneKit

class Universe: SCNScene {
    
    var camera: Camera!
    var sun: Sun!
    var planet: SCNNode!
    var stars: Stars!
    
    convenience init(radius z: Float) {
        self.init()
        
        lightingEnvironment.contents = UIImage(named: "envmap_blurred")
        lightingEnvironment.intensity = 4
        
        camera = Camera(at: z)
        rootNode.addChildNode(camera)
        
        sun = Sun(at: z)
        rootNode.addChildNode(sun)
        
        planet = Planet.node()
        rootNode.addChildNode(planet)
        
        stars = Stars()
        rootNode.addChildNode(stars)
        
        planet.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: -1, y: -1, z: -1, duration: 25)))
    }
}
