//
//  Stars.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 08/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation
import SceneKit

class Stars: SCNNode {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        guard let particles = SCNParticleSystem(named: "stars", inDirectory: "art.scnassets/") else { return }
        addParticleSystem(particles)
    }
}
