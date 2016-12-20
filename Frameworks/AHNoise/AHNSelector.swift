//
//  AHNSelector.swift
//  AHNoise
//
//  Created by Andrew Heard on 25/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import simd


/**
 The general class used to select between two input `AHNTextureProvider`s using a third input `AHNTextureProvider` and write it to an output. This class is not instantiated directly, but is used by various subclasses.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNSelector: NSObject, AHNTextureProvider{
  
  
  // MARK:- Properties
  
  
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
  
  
  
  ///The first input that will be combined with `provider2` using `selector` to provide the output.
  open var provider: AHNTextureProvider?{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The second input that will be combined with `provider` using `selector` to provide the output.
  open var provider2: AHNTextureProvider?{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The `AHNTextureProvider` that selects which input to write to the output `MTLTexture` depending on its value at each pixel.
  open var selector: AHNTextureProvider?{
    didSet{
      dirty = true
    }
  }
  
  
  
  /**
   The width of the output `MTLTexure`.
   
   This is dictated by the width of the texture of the first input `AHNTextureProvider`. If there is no input, the default width is `128` pixels.
   */
  open var textureWidth: Int{
    get{
      if let provider = provider, let provider2 = provider2, let selector = selector{
        return max(provider.textureSize().width, provider2.textureSize().width, selector.textureSize().width)
      }else{
        return 128
      }
    }
  }
  
  
  
  /**
   The height of the output `MTLTexure`.
   
   This is dictated by the height of the texture of the first input `AHNTextureProvider`. If there is no input, the default height is `128` pixels.
   */
  open var textureHeight: Int{
    get{
      if let provider = provider, let provider2 = provider2, let selector = selector{
        return max(provider.textureSize().height, provider2.textureSize().height, selector.textureSize().height)
      }else{
        return 128
      }
    }
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNSelector` object.
   
   To be called when instantiating a subclass.
   
   - parameter functionName: The name of the kernel function that this selector will use to modify the inputs.
   */
  init(functionName: String) {
    // Gather the context to use from the first input
    context = AHNContext.SharedContext
    
    // Load the kernel function and compute pipeline state
    guard let kernelFunction = context.library.makeFunction(name: functionName) else{
      fatalError("AHNoise: Error loading function \(functionName).")
    }
    self.kernelFunction = kernelFunction
    
    do{
      try pipeline = context.device.makeComputePipelineState(function: kernelFunction)
    }catch let error{
      fatalError("AHNoise: Error creating pipeline state for \(functionName).\n\(error)")
    }
    
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
   Override this method in subclasses to configure a uniform buffer to be sent to the kernel.
   
   - parameter commandEncoder: The `MTLComputeCommandEncoder` used to run the kernel. This can be used to lazily create a buffer of data and add it to the argument table. Any buffer index can be used without affecting the rest of this class.
   */
  open func configureArgumentTableWithCommandEncoder(_ commandEncoder: MTLComputeCommandEncoder){
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Texture Functions
  
  
  /**
   Updates the output `MTLTexture`.
   
   This should not need to be called manually as it is called by the `texture()` method automatically if the texture does not represent the current `AHNTextureProvider` properties.
   */
  open func updateTexture(){
    guard let provider1 = provider?.texture(), let provider2 = provider2?.texture(), let selector = selector?.texture() else { return }
    
    // Create the internalTexture if it equals nil or is the wrong size.
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
    commandEncoder.setTexture(provider1, at: 0)
    commandEncoder.setTexture(provider2, at: 1)
    commandEncoder.setTexture(selector, at: 2)
    commandEncoder.setTexture(internalTexture, at: 3)
    
    // Encode the uniform buffer
    configureArgumentTableWithCommandEncoder(commandEncoder)
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
  
  
  
  ///- returns: The updated output `MTLTexture` for the `AHNSelector`.
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
  
  
  
  ///- returns: The input `AHNTextureProvider` that provides the input `MTLTexture` to the `AHNSelector`. This is taken from `input1`. If there is no input, returns `nil`.
  open func textureProvider() -> AHNTextureProvider?{
    return provider
  }
  
  
  
  ///- returns: `False` if all inputs and the `internalTexture` do not need updating.
  open func isDirty() -> Bool {
    let dirtyProvider1 = provider?.isDirty() ?? false
    let dirtyProvider2 = provider2?.isDirty() ?? false
    let dirtySelector = selector?.isDirty() ?? false
    return dirtyProvider1 || dirtyProvider2 || dirtySelector || dirty
  }
  
  
  
  
  ///- returns: `False` if either of the two inputs or the selector is not set.
  open func canUpdate() -> Bool {
    return provider != nil && provider2 != nil && selector != nil
  }
}
