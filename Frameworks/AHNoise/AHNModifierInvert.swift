//
//  AHNModifierInvert.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and inverts the values.
 
 For example if a pixel has a value of `0.6`, the output will be `0.4`. The values are flipped around `0.5`.
  
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNModifierInvert: AHNModifier {

  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "invertModifier")
  }
}
