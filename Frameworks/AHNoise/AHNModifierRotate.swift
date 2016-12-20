//
//  AHNModifierRotate.swift
//  AHNoise
//
//  Created by Andrew Heard on 29/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and rotates its output.
 
 The `angle` property defines how much to rotate the input in radians.
 
 The result will be clipped to fit within the same frame as the input, the size of the canvas does not change. Corners may be clipped because of this, to avoid losing the corners, resize the canvas first by using an `AHNModifierScaleCanvas` object to provide more room for rotation.
 
 Values are interpolated to avoid pixellation.
 
 The centre point about which the rotation takes place can be defined by the `xAnchor` and `yAnchor` properties. These can vary from `(0.0,0.0)` for the bottom left to `(1.0,1.0)` for the top right. The default is `(0.5,0.5)`.
 
 Where the rotation results in the canvas being partially empty, this can be either left blank by setting `cutEdges` to `true`, or filled in black if set to `false`.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNModifierRotate: AHNModifier {

  
  // MARK:- Properties
  
  
  ///The anchor point for horizontal axis about which to rotate the input. The default value is `0.5`.
  open var xAnchor: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The anchor point for vertical axis about which to rotate the input. The default value is `0.5`.
  open var yAnchor: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The angle to rotate the input by in radians. The default value is `0.0`.
  open var angle: Float = 0.0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///When true, the edges of the input are "cut" before the rotation, meaning the black areas off the the canvas are not rotated and any area not covered by the input after rotation is clear. If false, these areas are filled black. The default value is `true`.
  open var cutEdges: Bool = true{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "rotateModifier")
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  open override func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = vector_float4(xAnchor, yAnchor, angle, cutEdges ? 1 : 0)
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<vector_float4>.stride, options: MTLResourceOptions())
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<vector_float4>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
