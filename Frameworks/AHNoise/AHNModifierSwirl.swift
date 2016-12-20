//
//  AHNModifierSwirl.swift
//  AHNoise
//
//  Created by Andrew Heard on 29/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and swirls its output.
 
 The `angle` property defines how much to swirl the input in radians. The amount each pixel is rotated about the anchor is proportional to its distance from the anchor point.
 
 The result will be clipped to fit within the same frame as the input, the size of the canvas does not change. Corners may be clipped because of this, to avoid losing the corners, resize the canvas first by using an `AHNModifierScaleCanvas` object to provide more room for rotation.
 
 Values are interpolated to avoid pixellation.
 
 The centre point about which the swirl takes place can be defined by the `xAnchor` and `yAnchor` properties. These can vary from `(0.0,0.0)` for the bottom left to `(1.0,1.0)` for the top right. The default is (`0.5,0.5`).
 
 Where the rotation results in the canvas being partially empty, this can be either left blank by setting `cutEdges` to `true`, or filled in black if set to `false`.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNModifierSwirl: AHNModifier {
  
  
  // MARK:- Properties
  
  
  
  ///The anchor point for horizontal axis about which to swirl the input. Default is `0.5`.
  open var xAnchor: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The anchor point for vertical axis about which to swirl the input. Default is `0.5`.
  open var yAnchor: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The intensity of the swirl. Default is `0.5`.
  open var intensity: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///When `true`, the edges of the input are "cut" before the swirl, meaning the black areas off the the canvas are not rotated and any area not covered by the input after rotation is clear. If `false`, these areas are filled black.
  open var cutEdges: Bool = true{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "swirlModifier")
  }
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  open override func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float4(xAnchor, yAnchor, intensity, cutEdges ? 1 : 0)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<vector_float4>.stride, options: MTLResourceOptions())
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<vector_float4>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
