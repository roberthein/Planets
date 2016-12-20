//
//  AHNGeneratorVoronoi.swift
//  Noise Studio
//
//  Created by App Work on 23/06/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import UIKit
import simd


///Struct used to communicate properties to the GPU.
struct VoronoiInputs {
  var pos: vector_float2
  var offsetStrength: Float
  var rotations: vector_float3
  var octaves: Int32
  var persistence: Float
  var frequency: Float
  var lacunarity: Float
  var zValue: Float
  var wValue: Float
  var sphereMap: Int32
  var seamless: Int32
}


///Generates a texture of discrete cells, useful for representing crystals or dried mud. The noise created lies within the range `0.0 - 1.0`.
///
///*Conforms to the `AHNTextureProvider` protocol.*
open class AHNGeneratorVoronoi: AHNGeneratorCoherent {

  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "voronoiGenerator")
    octaves = 1
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNGenerator` subclass. This should never be called directly.
  override open func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    super.configureArgumentTableWithCommandencoder(commandEncoder)
    var uniforms = VoronoiInputs(pos: vector_float2(xValue, yValue), offsetStrength: offsetStrength, rotations: vector_float3(xRotation, yRotation, zRotation), octaves: Int32(octaves), persistence: persistence, frequency: frequency, lacunarity: lacunarity, zValue: zValue, wValue: wValue, sphereMap: sphereMap ? 1 : 0, seamless: seamless ? 1 : 0)
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<VoronoiInputs>.stride, options: .storageModeShared)
    }
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<VoronoiInputs>.stride)
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 4)
  }
}
