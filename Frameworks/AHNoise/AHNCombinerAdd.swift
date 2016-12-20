//
//  AHNCombinerAdd.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Combines two input `AHNTextureProvider`s by adding their colour values together.
 
 For example a pixel with a value of `0.3` when added to another pixel with a value of `0.6` will result in a value of `0.9`.
 
 The `normalise` property indicates whether or not the resulting value should be normalised (divided by two) to return the output the the original value range and preventing output values from exceeding `1.0`. Setting this to `true` results in the ouput being the average of the two inputs.
 
 Resultant values larger than `1.0` will show as white. The addition is done separately for each colour channel, so the result does not default to greyscale.
 */
open class AHNCombinerAdd: AHNCombiner {
  
  
  // MARK:- Properties
  
  
  ///When set to `true` (`false` by default) the output value range is remapped back to `0.0 - 1.0` to prevent overly bright areas where the combination of inputs has exceeded `1.0`. Setting this to `true` results in the output being the average of the two inputs.
  open var normalise: Bool = false{
    didSet{
      dirty = true
    }
  }
  
  

  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  

  required public init(){
    super.init(functionName: "addCombiner")
  }
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNCombiner` subclass. This should never be called directly.
  open override func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = normalise
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<Bool>.stride, options: .storageModeShared)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<Bool>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
