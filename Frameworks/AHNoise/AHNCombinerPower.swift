//
//  AHNCombinerPower.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Combines two input `AHNTextureProvider`s by raising the power of the first input to the second input.
 
 The value of the output is calculated using: `output = pow(input1.rgb, input2.rgb)`.
 
 For example a pixel with a noise value of `0.3` when raised to the power of another pixel with a noise value of `0.6` will result in a noise value of `0.486`.
 
 The multiplication is done separately for each colour channel, so the result does not default to greyscale.
 */
open class AHNCombinerPower: AHNCombiner{

  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "powerCombiner")
  }
}
