//
//  Planet.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 08/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation
import SceneKit

class Planet {
    
    static func node() -> SCNNode? {
        let planetScene = SCNScene(named: "art.scnassets/planet.obj")
        return planetScene?.rootNode.childNodes[0]
    }
}
