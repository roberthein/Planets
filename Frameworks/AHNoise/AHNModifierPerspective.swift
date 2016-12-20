//
//  AHNModifierPerspective.swift
//  AHNoise
//
//  Created by Andrew Heard on 29/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd

/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and applies a perspective transform.
 
 The `xCompression` property determines how much the upper portion of the input is compressed horizontally to give the impression of stretching into the distance. Values over `3.3` will result in the texture wrapping. A value of `2 - 2.5` is a good place to start.
 
 The `yScale` property determines how much the input is scaled in the vertical axis to give an impression of looking at the canvas at a shallow angle. This can range from `0.0 - 1.0`. at `0.0` the canvas has zero height, at `1.0` it retains its original height.
 
 The `direction` property allows the direction of the perspective to be skewed left (using negative values) or right (using positive values) to give the impression a horizontal receding angle.
 
 Values are interpolated to avoid pixellation.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNModifierPerspective: AHNModifier {

  
  // MARK:- Properties
  
  
  ///The amount to compress the texture horizontally to give the impression of stretching into the distance. Values over `3.3` will result in the texture wrapping. A value of `2 - 2.5` is a good place to start. The default value is `2`.
  open var xCompression: Float = 2{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The amount to scale the texture vertically to give an impression of looking at the canvas at a shallow angle. This can range from `0.0 - 1.0`. at `0.0` the canvas has zero height, at `1.0` it retains its original height. The default value is `0.5`.
  open var yScale: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///Allows the direction of the perspective to be skewed left (using negative values) or right (using positive values) to give the impression a horizontal receding angle. The default value is `0.0.`
  open var direction: Float = 0{
    didSet{
      dirty = true
    }
  }


  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "perspectiveModifier")
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  open override func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float3(xCompression, yScale, direction)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<vector_float3>.stride, options: MTLResourceOptions())
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<vector_float3>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
