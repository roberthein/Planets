//
//  AHNCombinerMax.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Combines two input `AHNTextureProvider`s by choosing the maximum value of the two.
 
 The value of the output is calculated by first calculating the average value of the three colour channels, then selecting the maximum value and writing the three channels to the output in order to retain colour.
 
 For example a pixel with a noise value of `0.3` when compared with another pixel with a noise value of `0.6` will result in a noise value of `0.6`.
 */
open class AHNCombinerMax: AHNCombiner {
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "maxCombiner")
  }
}
