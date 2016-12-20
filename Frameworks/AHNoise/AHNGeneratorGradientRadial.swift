//
//  AHNGeneratorGradientRadial.swift
//  Noise Studio
//
//  Created by App Work on 07/07/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import UIKit
import simd


///Generates a radial gradient texture originating from a control point.
///
///*Conforms to the `AHNTextureProvider` protocol.*
open class AHNGeneratorGradientRadial: AHNGenerator {
  
  
  // MARK:- Properties
  
  
  ///The location along the x axis of the control point that the gradient is centred on. A value of `0.0` corresponds to the left hand  edge and a value of `1.0` corresponds to the right hand edge. The default value is `0.5`.
  open var xPosition: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The location along the y axis of the control point that the gradient is centred on. A value of `0.0` corresponds to the bottom edge and a value of `1.0` corresponds to the top edge. The default value is `0.5`.
  open var yPosition: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The horizontal falloff of the radial gradient. A value of `1.0` results in the gradient terminating at the edges of the texture, lower values cause the gradient to extend beyond the edge of the texture and vice versa.
  open var xFallOff: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The vertical falloff of the radial gradient. A value of `1.0` results in the gradient terminating at the edges of the texture, lower values cause the gradient to extend beyond the edge of the texture and vice versa.
  open var yFallOff: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "radialGradientGenerator")
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNGenerator` subclass. This should never be called directly.
  override open func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = GradientInputs(positions: vector_float4(xPosition, yPosition, xFallOff, yFallOff), offsetStrength: offsetStrength, rotations: vector_float3(xRotation, yRotation, zRotation))
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<GradientInputs>.stride, options: .storageModeShared)
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<GradientInputs>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
}
