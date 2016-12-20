//
//  Camera.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 08/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation
import SceneKit

class Camera: SCNNode {
    
    convenience init(at distance: Float) {
        self.init()
        
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = false
        camera.zNear = 0.0001
        camera.zFar = 999999999
        self.camera = camera
        
        position = SCNVector3Make(0, 0, 0)
        pivot = SCNMatrix4MakeTranslation(0, 0, -distance)
    }
}
