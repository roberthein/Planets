//
//  AHNModifierStep.swift
//  AHNoise
//
//  Created by Andrew Heard on 24/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and maps values larger than the `boundary` value to the `highValue`, and those below to the `lowValue`.
 
 For example if a pixel has a value of `0.6`, the `boundary` is set to `0.5`, the `highValue` set to `0.7` and the `lowValue` set to `0.1`, the returned value will be `0.1`.
 
 The output of this module will always be greyscale as the output value is written to all three colour channels equally.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNModifierStep: AHNModifier{
  
  
  // MARK:- Properties
  
  
  ///The low value (default value is `0.0`) to output if the noise value is lower than the `boundary`.
  open var lowValue: Float = 0{
    didSet{
      dirty = true
    }
  }

  
  
  ///The hight value (default value is `1.0`) to output if the noise value is higher than the `boundary`.
  open var highValue: Float = 1{
    didSet{
      dirty = true
    }
  }

  
  
  ///The value at which to perform the step. Texture values lower than this are returned as `lowValue` and those above are returned as `highValue`. The default value is `0.5`.
  open var boundary: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "stepModifier")
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  open override func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float3(lowValue, highValue, boundary)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<vector_float3>.stride, options: MTLResourceOptions())
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<vector_float3>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
