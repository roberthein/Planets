//
//  AHNCombinerDivide.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Combines two input `AHNTextureProvider`s by dividing their colour values by one another.
 
 The value of the output is calculated using: `output = input1.rgb / input2.rgb`.
 
 For example a pixel with a value of `0.3` when divided by another pixel with a value of `0.6` will result in a value of `0.5`.
 
 Resultant values larger than `1.0` will show as white, and lower than `0.0` will show as black. The division is done separately for each colour channel, so the result does not default to greyscale.
 */
open class AHNCombinerDivide: AHNCombiner {

  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "divideCombiner")
  }
}
