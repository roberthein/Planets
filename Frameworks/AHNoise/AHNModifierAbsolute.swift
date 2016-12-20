//
//  AHNModifierAbsolute.swift
//  AHNoise
//
//  Created by Andrew Heard on 24/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and performs a mathematical `abs()` function on the pixel values.
 
 Pixel values are in the range `0.0 - 1.0`, and apply the `abs()` function to this range would have no effect. This means the pixel valeus must be converted back to the original `-1.0 - 1.0` noise range, then perform the `abs()` function, then finally convert back into the colour range `0.0 - 1.0`. This results in outputs in the range `0.5 - 1.0`.
 
 If the `normalise` property is `true` (`false` by default) then the output values will be remapped to `0.0 - 1.0`, essentially stretching the to fit the original range.
 
 *Conforms to the `AHNTextureProvider` protocol.*
*/
open class AHNModifierAbsolute: AHNModifier {
  

  // MARK:- Properties
  
  
  ///If `false` (the default), the output is within the range `0.5 - 1.0`, if `true` the output is remapped to cover the whole `0.0 - 1.0` range of the input.
  open var normalise: Bool = false{
    didSet{
      dirty = true
    }
  }

  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "absoluteModifier")
  }
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  open override func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = normalise
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<Bool>.stride, options: MTLResourceOptions())
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<Bool>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
