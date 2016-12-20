//
//  AHNContext.swift
//  AHNoise
//
//  Created by Andrew Heard on 22/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import UIKit
import Metal
import simd


/**
 A wrapper for the `MTLDevice`, `MTLLibrary` and `MTLCommandQueue` used to create the noise textures. Used when generating noise textures using an `AHNGenerator` subclass.
 
 `AHNModifier`, `AHNCombiner` and `AHNSelector` require an `AHNContext` to run, but reference the same `AHNContext` object as their input, which comes from the `Shared Context` class property for `AHNGenerators`.
 */
open class AHNContext: NSObject {
  
  
  // MARK:- Static Functions
  
  ///The shared `AHNContext` object that is used by all `AHNTextureProvider` objects to communicate with the GPU.
  static var SharedContext: AHNContext! = AHNContext.CreateContext()
  
  
  
  ///Set the `MTLDevice` of the `SharedContect` object to a specific object. An `MTLDevice` is a representation of a GPU, so apps for macOS (OSX) will want to set the device to the most powerful graphics hardware available, and not automatically default to onboard graphics.
  static func SetContextDevice(_ device: MTLDevice){
    SharedContext = CreateContext(device)
  }
  
  
  
  ///- returns: An `AHNContext` object with the specified `MTLDevice`. If no `MTLDevice` is specified then the default is obtained from `MTLCreateSystemDefaultDevice()`.
  fileprivate static func CreateContext(_ device: MTLDevice? = MTLCreateSystemDefaultDevice()) -> AHNContext{
    return AHNContext(device: device)
  }
  
  
  
  
  
  // MARK:- Properties
  
  
  ///The `MTLDevice` used by the various noise classes to create buffers, pipelines and command encoders.
  open let device: MTLDevice
  
  
  
  ///The `MTLLibrary` that stores the `Metal` kernel functions used to create an manipulate noise.
  open let library: MTLLibrary
  
  
  
  ///The `MTLCommandQueue` that is used to create `MTLCommandEncoder`s for each kernel.
  open let commandQueue: MTLCommandQueue
  
  
  
  internal var grad3Buffer: MTLBuffer
  
  
  
  internal var grad4Buffer: MTLBuffer
  
  
  
  internal var permBuffer: MTLBuffer
  
  
  
  internal var permMod12Buffer: MTLBuffer
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNContext` object for use with `AHNoise` modules.
   
   - parameter device: (Optional) The `MTLDevice` used throughout the `AHNoise` framework..
   */
  private init(device: MTLDevice?) {
    guard let device = device else{
      fatalError("AHNoise: Error creating MTLDevice).")
    }
    self.device = device
    
    guard let library = device.newDefaultLibrary() else{
      fatalError("AHNoise: Error creating default library.")
    }
    self.library = library
    
    commandQueue = device.makeCommandQueue()
    
    
    var grad3 = [float3(1,1,0), float3(-1,1,0), float3(1,-1,0), float3(-1,-1, 0), float3(1,0,1), float3(-1,0,1), float3(1,0,-1), float3(-1,0,-1), float3(0,1,1), float3(0,-1,1), float3(0,1,-1), float3(0,-1,-1)]
    grad3Buffer = device.makeBuffer(bytes: &grad3, length: MemoryLayout<float3>.size * grad3.count, options: MTLResourceOptions.storageModeShared)
    
    var grad4 = [float4(0,1,1,1), float4(0,1,1,-1), float4(0,1,-1,1), float4(0,1,-1,-1), float4(0,-1,1,1), float4(0,-1,1,-1), float4(0,-1,-1,1), float4(0,-1,-1,-1), float4(1,0,1,1), float4(1,0,1,-1), float4(1,0,-1,1), float4(1,0,-1,-1), float4(-1,0,1,1), float4(-1,0,1,-1), float4(-1,0,-1,1), float4(-1,0,-1,-1), float4(1,1,0,1), float4(1,1,0,-1), float4(1,-1,0,1), float4(1,-1,0,-1), float4(-1,1,0,1), float4(-1,1,0,-1), float4(-1,-1,0,1), float4(-1,-1,0,-1), float4(1,1,1,0), float4(1,1,-1,0), float4(1,-1,1,0), float4(1,-1,-1,0), float4(-1,1,1,0), float4(-1,1,-1,0), float4(-1,-1,1,0), float4(-1,-1,-1,0)]
    grad4Buffer = device.makeBuffer(bytes: &grad4, length: MemoryLayout<float4>.size * grad4.count, options: .storageModeShared)
    
    var perm: [Int32] = [151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180]
    permBuffer = device.makeBuffer(bytes: &perm, length: MemoryLayout<Int32>.size * perm.count, options: .storageModeShared)
    
    var permMod12: [Int32] = [7,4,5,7,6,3,11,1,9,11,0,5,2,5,7,9,8,0,7,6,9,10,8,3,1,0,9,10,11,10,6,4,7,0,6,3,0,2,5,2,10,0,3,11,9,11,11,8,9,9,9,4,9,5,8,3,6,8,5,4,3,0,8,7,2,9,11,2,7,0,3,10,5,2,2,3,11,3,1,2,0,7,1,2,4,9,8,5,7,10,5,4,4,6,11,6,5,1,3,5,1,0,8,1,5,4,0,7,4,5,6,1,8,4,3,10,8,8,3,2,8,4,1,6,5,6,3,4,4,1,10,10,4,3,5,10,2,3,10,6,3,10,1,8,3,2,11,11,11,4,10,5,2,9,4,6,7,3,2,9,11,8,8,2,8,10,7,10,5,9,5,11,11,7,4,9,9,10,3,1,7,2,0,2,7,5,8,4,10,5,4,8,2,6,1,0,11,10,2,1,10,6,0,0,11,11,6,1,9,3,1,7,9,2,11,11,1,0,10,7,1,7,10,1,4,0,0,8,7,1,2,9,7,4,6,2,6,8,1,9,6,6,7,5,0,0,3,9,8,3,6,6,11,1,0,0,7,4,5,7,6,3,11,1,9,11,0,5,2,5,7,9,8,0,7,6,9,10,8,3,1,0,9,10,11,10,6,4,7,0,6,3,0,2,5,2,10,0,3,11,9,11,11,8,9,9,9,4,9,5,8,3,6,8,5,4,3,0,8,7,2,9,11,2,7,0,3,10,5,2,2,3,11,3,1,2,0,7,1,2,4,9,8,5,7,10,5,4,4,6,11,6,5,1,3,5,1,0,8,1,5,4,0,7,4,5,6,1,8,4,3,10,8,8,3,2,8,4,1,6,5,6,3,4,4,1,10,10,4,3,5,10,2,3,10,6,3,10,1,8,3,2,11,11,11,4,10,5,2,9,4,6,7,3,2,9,11,8,8,2,8,10,7,10,5,9,5,11,11,7,4,9,9,10,3,1,7,2,0,2,7,5,8,4,10,5,4,8,2,6,1,0,11,10,2,1,10,6,0,0,11,11,6,1,9,3,1,7,9,2,11,11,1,0,10,7,1,7,10,1,4,0,0,8,7,1,2,9,7,4,6,2,6,8,1,9,6,6,7,5,0,0,3,9,8,3,6,6,11,1,0,0]
    permMod12Buffer = device.makeBuffer(bytes: &permMod12, length: MemoryLayout<Int32>.size * permMod12.count, options: .storageModeShared)

  }
}
