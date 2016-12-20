//
//  AHNModifierScaleCanvas.swift
//  AHNoise
//
//  Created by Andrew Heard on 29/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import UIKit
import Metal
import simd


///The struct used to encode user defined properties (uniforms) to the GPU.
struct AHNScaleCanvasProperties{
  var scale: vector_float4
  var oldSize: vector_int4
}


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and scales and repositions it in its texture.
 
 The `xScale` and `yScale` (`1.0, 1.0` by default) properties allow you to stretch or shrink a texture within the new canvas, and the `xAnchor` and `yAnchor` (`0.0,0.0` by default) properties allow you to move the bottom left hand corner of the input to reposition it within the new canvas. An anchor value of `0.0` leaves the input at the origin, whereas a value of `1.0` moves it to the other extreme of the canvas.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNModifierScaleCanvas: NSObject, AHNTextureProvider {
  
  
  //MARK:- Properties
  
  
  ///The `AHNContext` that is being used by the `AHNTextureProvider` to communicate with the GPU. This is recovered from the first `AHNGenerator` class that is encountered in the chain of classes.
  open var context: AHNContext
  
  
  
  ///The `MTLComputePipelineState` used to run the `Metal` compute kernel on the GPU.
  let pipeline: MTLComputePipelineState
  
  
  
  ///The `MTLBuffer` used to transfer the constant values used by the compute kernel to the GPU.
  open var uniformBuffer: MTLBuffer?
  
  
  
  ///The `MTLTexture` that the compute kernel writes to as an output.
  var internalTexture: MTLTexture?
  
  
  
  /**
   The `MTLFunction` compute kernel that modifies the input `MTLTexture`s and writes the output to the `internalTexture` property.
   
   The function used is specific to each class.
   */
  let kernelFunction: MTLFunction
  
  
  
  ///Indicates whether or not the `internalTexture` needs updating.
  open var dirty: Bool = true
  
  
  
  ///The input that will be modified using to provide the output.
  open var provider: AHNTextureProvider?{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The width of the new `MTLTexture`
  open var textureWidth: Int = 128{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The height of the new `MTLTexture`
  open var textureHeight: Int = 128{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The position along the horizontal axis of the bottom left corner of the input in the new canvas. Ranges from `0.0` for far left to `1.0` for far right, though values beyond this can be used. Default value is `0.0`.
  open var xAnchor: Float = 0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The position along the vertical axis of the bottom left corner of the input in the new canvas. Ranges from `0.0` for the bottom to `1.0` for the top, though values beyond this can be used. Default value is `0.0`.
  open var yAnchor: Float = 0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The scale of the input when inserted into the canvas. If an input had a width of `256`, which is being resized to `512` with a scale of `0.5`, the width of the input would be `128` in the canvas of `512`. Default value is `1.0`.
  open var xScale: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The scale of the input when inserted into the canvas. If an input had a height of `256`, which is being resized to `512` with a scale of `0.5`, the height of the input would be `128` in the canvas of `512`. Default value is `1.0`.
  open var yScale: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  override public required init(){
    context = AHNContext.SharedContext
    let functionName = "scaleCanvasModifier"
    
    guard let kernelFunction = context.library.makeFunction(name: functionName) else{
      fatalError("AHNoise: Error loading function \(functionName).")
    }
    self.kernelFunction = kernelFunction
    
    do{
      try pipeline = context.device.makeComputePipelineState(function: kernelFunction)
    }catch{
      fatalError("AHNoise: Error creating pipeline state for \(functionName).\n\(error)")
    }
    super.init()
  }

  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier`. This should never be called directly.
  open func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    var uniforms = AHNScaleCanvasProperties(scale: vector_float4(xAnchor, yAnchor, xScale, yScale), oldSize: vector_int4(Int32(provider!.textureSize().width), Int32(provider!.textureSize().height),0,0))
    
    if uniformBuffer == nil{
      uniformBuffer = context.device.makeBuffer(length: MemoryLayout<AHNScaleCanvasProperties>.stride, options: MTLResourceOptions())
    }
    
    memcpy(uniformBuffer!.contents(), &uniforms, MemoryLayout<AHNScaleCanvasProperties>.stride)
    
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Texture Functions
  
  
  /**
   Updates the output `MTLTexture`.
   
   This should not need to be called manually as it is called by the `texture()` method automatically if the texture does not represent the current `AHNTextureProvider` properties.
   */
  open func updateTexture(){
    if provider == nil {return}

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
    commandEncoder.setTexture(provider!.texture(), at: 0)
    commandEncoder.setTexture(internalTexture, at: 1)
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
  }
  

  
  ///- returns: The updated output `MTLTexture` for this module.
  open func texture() -> MTLTexture?{
    if isDirty(){
      updateTexture()
    }
    return internalTexture
  }
  
  
  
  ///- returns: The MTLSize of the the output `MTLTexture`. If no size has been explicitly set, the default value returned is `128x128` pixels.
  open func textureSize() -> MTLSize{
    return MTLSizeMake(textureWidth, textureHeight, 1)
  }
  
  
  
  ///- returns: The input `AHNTextureProvider` that provides the input `MTLTexture` to the `AHNModifier`. This is taken from the `input`. If there is no `input`, returns `nil`.
  open func textureProvider() -> AHNTextureProvider?{
    return provider
  }
  
  
  
  ///- returns: `False` if the input and the `internalTexture` do not need updating.
  open func isDirty() -> Bool {
    if let p = provider{
      return p.isDirty() || dirty
    }else{
      return dirty
    }
  }
  
  
  
  ///-returns: `False` if the `provider` is not set.
  open func canUpdate() -> Bool {
    return provider != nil
  }
}
