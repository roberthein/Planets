//
//  AHNSelectorBlend.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Blends two input `AHNTextureProvider`s together using a weight from a third input `AHNTextureProvider` used as the `selector`.
 
 The input `AHNTextureProvider`s may range from a value of `0.0 - 1.0`. This value is taken from the `selector` for each pixel to provide a mixing weight for the two `provider`s. A value of `0.0` will output 100% `provider` and 0% `provider2`, while a value of `1.0` will output 100% `provider2` and 0% `provider`. A value of `0.25` will output a mixture of 75% `provider` and 25% `provider2`.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNSelectorBlend: AHNSelector {
  

  // MARK:- Initialiser
  

  required public init(){
    super.init(functionName: "blendSelector")
  }
}
