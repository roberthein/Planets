//
//  AHNSelectorSelect.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Selects one of two input `AHNTextureProvider`s to write to the output using a weight from a third input `AHNTextureProvider` used as the `selector`.
 
 The input `AHNTextureProvider`s may range from a value of `0.0 - 1.0`. This value is taken from the `selector` `AHNTextureProvider` for each pixel to select which input to write to the output `MTLTexture`. A `selector` value between `0.0 - boundary` will result in `provider` being written to the output, whereas a `selector` value between `boundary - 1.0` will result in `provider2` being written to the output.
 
 The `edgeTransition` property is used to define how abruptly the transition occurs between the two inputs. A value of `0.0` will result in no transition. Higher values cause the transition to be softened by interpolating between the two inputs at the border between them. A maximum value of `1.0` results in the edge transition covering the whole of the two inputs.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNSelectorSelect: AHNSelector {
  
  
  // MARK:- Properties
  
  
  /** 
   The amount the transition between the two inputs should be softened `(0.0 - 1.0)`.
   
   Values outside the range `(0.0 - 1.0)` may result in undesired behaviour.
   
   Default value is `0.0`.
 */
  var transition: Float = 0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The boundary that the selector value is compared to. Selector values larger than this boundary will output `provider2`, and less than this will output `provider`. The default value is `0.5`.
  var boundary: Float = 0.5{
    didSet{
      dirty = true
    }
  }


  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "selectSelector")
  }
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNSelector` subclass. This should never be called directly.
  open override func configureArgumentTableWithCommandEncoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float2(transition, boundary)
    
    // Create the uniform buffer
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<vector_float2>.stride, options: MTLResourceOptions())
    }
    
    // Copy latest arguments
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<vector_float2>.stride)
    
    // Set the buffer in the argument table
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
