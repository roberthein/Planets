//
//  AHNGenerator.swift
//  Noise Studio
//
//  Created by App Work on 23/06/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import UIKit

/**
 The general class used to output a procedurally generated texture. This class is not instantiated directly, but is used by various subclasses.
 
 The output texture represents a 2D slice through a 3D geometric or noise function that can optionally be distorted in the x and y axes.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNGenerator: NSObject, AHNTextureProvider {  
  // MARK:- Properties  
  ///The `AHNContext` that is being used by the `AHNTextureProvider` to communicate with the GPU. This is taken from the `SharedContext` class property of `AHNContext`.
  open var context: AHNContext  
  ///The `MTLComputePipelineState` used to run the `Metal` compute kernel on the GPU.
  let pipeline: MTLComputePipelineState  
  ///The `MTLBuffer` used to communicate the constant values used by the compute kernel to the GPU.
  open var uniformBuffer: MTLBuffer?  
  ///The `MTLTexture` that the compute kernel writes to as an output.
  var internalTexture: MTLTexture?  
  ///The default uniform greyscale texture to use as a displacement texture that results in zero displacement.
  var defaultDisplaceTexture: MTLTexture?  
  ///The texture to offset pixels by in the x axis. Pixel values less than `0.5` offset to the left, and above `0.5` offset to the right.
  open var xoffsetInput: AHNTextureProvider?{
    didSet{
      dirty = true
    }
  }  
  ///The texture to offset pixels by in the y axis. Pixel values less than `0.5` offset downwards, and above `0.5` offset upwards.
  open var yoffsetInput: AHNTextureProvider?{
    didSet{
      dirty = true
    }
  }  
  ///The intensity of the effects of the `xoffsetInput` and `yoffsetInput`. A value of `0.0` results in no displacement. The default value is `0.2`.
  open var offsetStrength: Float = 0.2{
    didSet{
      dirty = true
    }
  }  
  ///The angle (in radians) by which to rotate the 2D slice of the texture about the x axis of the 3D space of the geometric or noise `kernelFunction`. The default value is `0.0`.
  open var xRotation: Float = 0{
    didSet{
      dirty = true
    }
  }  
  ///The angle (in radians) by which to rotate the 2D slice of the texture about the y axis of the 3D space of the geometric or noise `kernelFunction`. The default value is `0.0`.
  open var yRotation: Float = 0{
    didSet{
      dirty = true
    }
  }  
  ///The angle (in radians) by which to rotate the 2D slice of the texture about the z axis of the 3D space of the geometric or noise `kernelFunction`. The default value is `0.0`.
  open var zRotation: Float = 0{
    didSet{
      dirty = true
    }
  }  
  /**
   The `MTLFunction` compute kernel that generates the output `MTLTexture` property.
   
   The function used is specific to each class.
   */
  let kernelFunction: MTLFunction  
  ///Indicates whether or not the `internalTexture` needs updating.
  open var dirty: Bool = true  
  /**
   The width of the output `MTLTexure` in pixels. The default value is `128`.
   */
  open var textureWidth: Int = 128{
    didSet{
      dirty = true
    }
  }  
  /**
   The height of the output `MTLTexure` in pixels. The default value is `128`.
   */
  open var textureHeight: Int = 128{
    didSet{
      dirty = true
    }
  }  
  // MARK:- Inititalisers  
  /**
   Creates a new `AHNGenerator` object.
   
   To be called when instantiating a subclass.
   
   - parameter functionName: The name of the kernel function that this generator will use to create an output.
   */
  public init(functionName: String){
    context = AHNContext.SharedContext
    guard let kernelFunction = context.library.makeFunction(name: functionName) else{
      fatalError("AHNoise: Error loading function \(functionName).")
    }
    self.kernelFunction = kernelFunction
    
    do{
      try pipeline = context.device.makeComputePipelineState(function: kernelFunction)
    }catch let error{
      fatalError("AHNoise: Error creating pipeline state for \(functionName).\n\(error)")
    }
    dirty = true
    super.init()
  }  
  override public required init(){
    context = AHNContext.SharedContext
    // Load the kernel function and compute pipeline state
    guard let kernelFunction = context.library.makeFunction(name: "simplexGenerator") else{
      fatalError("AHNoise: Error loading function simplexGenerator.")
    }
    self.kernelFunction = kernelFunction
    
    do{
      try pipeline = context.device.makeComputePipelineState(function: kernelFunction)
    }catch let error{
      fatalError("AHNoise: Error creating pipeline state for simplexGenerator.\n\(error)")
    }
    
    super.init()
  }  
  // MARK:- Configure Uniforms  
  /**
   This function is overridden by subclasses to  write class specific variables to the `uniformBuffer`.
   
   - parameter commandEncoder: The `MTLComputeCommandEncoder` used to run the kernel. This can be used to lazily create a buffer of data and add it to the argument table. Any buffer index can be used without affecting the rest of this class.
   */
  open func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder){
  }  
  // MARK:- Texture Functions  
  /**
   Updates the output `MTLTexture`.
   
   This should not need to be called manually as it is called by the `texture()` method automatically if the texture does not represent the current properties.
   */
  open func updateTexture(){
    if internalTexture == nil{
      newInternalTexture()
    }
    if internalTexture!.width != textureWidth || internalTexture!.height != textureHeight{
      newInternalTexture()
    }
    
    let threadGroupsCount = MTLSizeMake(8, 8, 1)
    let threadGroups = MTLSizeMake(textureWidth / threadGroupsCount.width, textureHeight / threadGroupsCount.height, 1)
    
    let commandBuffer = context.commandQueue.makeCommandBuffer()
    
    let commandEncoder = commandBuffer.makeComputeCommandEncoder()
    commandEncoder.setComputePipelineState(pipeline)
    commandEncoder.setTexture(internalTexture, at: 0)
    commandEncoder.setTexture(xoffsetInput?.texture() ?? defaultDisplaceTexture!, at: 1)
    commandEncoder.setTexture(yoffsetInput?.texture() ?? defaultDisplaceTexture!, at: 2)

    configureArgumentTableWithCommandencoder(commandEncoder)
    commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupsCount)
    commandEncoder.endEncoding()
    
    commandBuffer.commit()
    commandBuffer.waitUntilCompleted()
    
    dirty = false
  }  
  ///Create a new `internalTexture` for the first time or whenever the texture is resized.
  func newInternalTexture(){
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: textureWidth, height: textureHeight, mipmapped: false)
    internalTexture = context.device.makeTexture(descriptor: textureDescriptor)
    
    let grey: [UInt8] = [128, 128, 128, 255]
    var textureBytes: [UInt8] = []
    for _ in 0..<textureWidth*textureHeight{
      textureBytes.append(contentsOf: grey)
    }
    textureDescriptor.usage = .shaderRead
    defaultDisplaceTexture = context.device.makeTexture(descriptor: textureDescriptor)
    defaultDisplaceTexture?.replace(region: MTLRegionMake2D(0, 0, textureWidth, textureHeight), mipmapLevel: 0, withBytes: &textureBytes, bytesPerRow: 4*textureWidth)
  }  
  // Texture Provider
  ///- returns: The updated output `MTLTexture` for this module.
  open func texture() -> MTLTexture?{
    if isDirty(){
      updateTexture()
    }
    return internalTexture
  }  
  ///- returns: The size of the output `MTLTexture`.
  open func textureSize() -> MTLSize{
    return MTLSizeMake(textureWidth, textureHeight, 1)
  }  
  ///- returns: A boolean value indicating whether or not the texture need updating to include updated properties.
  open func isDirty() -> Bool {
    let dirtyProvider1 = xoffsetInput?.isDirty() ?? false
    let dirtyProvider2 = yoffsetInput?.isDirty() ?? false
    return dirtyProvider1 || dirtyProvider2 || dirty
  }  
  ///- returns: `True` as this a generator can always update.
  open func canUpdate() -> Bool {
    return true
  }
}
