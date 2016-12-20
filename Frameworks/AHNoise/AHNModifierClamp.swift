//
//  AHNModifierClamp.swift
//  AHNoise
//
//  Created by Andrew Heard on 24/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


///The struct used to encode user defined properties (uniforms) to the GPU.
struct ClampModifierUniforms {
  var normalise: Bool
  var clampValues: vector_float2
}


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and performs a `clamp()` function on the pixel values.
 
 The output of the `AHNGenerator` classes returns value in the range `0.0 - 1.0`, this module will perform a clamp function on the input, reverting any values over a specified maximum value to that maximum value, and the same for any values less than a specified minimum value. If the `normalise` property is true (false by default) then the output values will be remapped to `0.0 - 1.0`, essentially stretching the to fit the original range.
 
 For example if a pixel has a value of `0.9` and the `maximum` property is set to `0.75`, the returned value will be `0.75`. The same applies for a value less than the minimum value.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNModifierClamp: AHNModifier {
  
  
  // MARK:- Properties
  
  
  ///If `false` (default), the output is within the range `minimum - maximum, if `true` the output is remapped to cover the whole `0.0 - 1.0` range of the input.
  open var normalise: Bool = false{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The maximum value of the range to clamp to. Values larger than this will be written to the output as this value. The default value is `1.0`.
  open var minimum: Float = 0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The minimum value of the range to clamp to. Values smaller than this will be written to the output as this value. The default value is `0.0`.
  open var maximum: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "clampModifier")
  }

  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  open override func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = ClampModifierUniforms(normalise: normalise, clampValues: vector_float2(minimum, maximum))
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<ClampModifierUniforms>.stride, options: MTLResourceOptions())
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<ClampModifierUniforms>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
