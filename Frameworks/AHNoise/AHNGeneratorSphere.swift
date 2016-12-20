//
//  AHNGeneratorphere.swift
//  Noise Studio
//
//  Created by App Work on 23/06/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import UIKit
import simd


///Generates a texture representing a slice through a field of concentric spheres.
///
///*Conforms to the `AHNTextureProvider` protocol.*
open class AHNGeneratorSphere: AHNGenerator {
  
  
  // MARK:- Properties
  
  
  ///The distance to offset the first sphere from the centre by. The default value is `0.0`.
  open var offset: Float = 0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The frequency of the spheres, higher values result in more, closer packed spheres. The default value is `1.0`.
  open var frequency: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The position along the x axis that the spheres are centred on. A value of `0.0` corresponds to the left texture edge, and a value of `1.0` cooresponds to the right texture edge. The default value is `0.5`.
  open var xPosition: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The position along the y axis that the spheres are centred on. A value of `0.0` corresponds to the bottom texture edge, and a value of `1.0` cooresponds to the top texture edge. The default value is `0.5`.
  open var yPosition: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The value along the z axis that the texture slice is taken. The default value is `0.0`.
  open var zValue: Float = 0{
    didSet{
      dirty = true
    }
  }

  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "sphereGenerator")
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNGenerator` subclass. This should never be called directly.
  override open func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = GeometricInputs(offset: offset, frequency: frequency, xPosition: xPosition, yPosition: yPosition, zValue: zValue, offsetStrength: offsetStrength, rotations: vector_float3(xRotation, yRotation, zRotation))
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<GeometricInputs>.stride, options: .storageModeShared)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<GeometricInputs>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
