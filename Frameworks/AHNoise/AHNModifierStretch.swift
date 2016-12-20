//
//  AHNModifierStretch.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and stretches its output.
 
 The `xFactor` and `yFactor` properties define how much to stretch the input in each direction. A factor of `1.0` will result in no change in that axis, but a factor of `2.0` will result in the dimension of that axis being doubled. Factors less than `1.0` can be used to shrink a canvas. The default is (`1.0,1.0`)
 
 The result will be clipped to fit within the same frame as the input, the size of the canvas does not change.
 
 Values are interpolated to avoid pixellation.
  
 The centre point about which the stretch takes place can be defined by the `xAnchor` and `yAnchor` properties. These can vary from `(0.0,0.0)` for the bottom left to `(1.0,1.0)` for the top right. The default is `(0.5,0.5)`
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNModifierStretch: AHNModifier {

  
  // MARK:- Properties
  
  
  ///The factor to stretch the input by in the horizontal axis. Default value is `1.0`.
  open var xFactor: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The factor to stretch the input by in the vertical axis. Default value is `1.0`.
  open var yFactor: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The anchor point for horizontal axis about which to stretch the input. Default is `0.5`.
  open var xAnchor: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The anchor point for vertical axis about which to stretch the input. Default is `0.5`.
  open var yAnchor: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "stretchModifier")
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  open override func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float4(xFactor, yFactor, xAnchor, yAnchor)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<vector_float4>.stride, options: MTLResourceOptions())
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<vector_float4>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
