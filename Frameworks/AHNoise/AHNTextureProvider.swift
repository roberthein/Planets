//
//  AHNTextureProvider.swift
//  AHNoise
//
//  Created by Andrew Heard on 22/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import Metal
import UIKit
import simd



// MARK:- AHNTextureProvider


///Implemented by classes that output an `MTLTexture`. Provides references to textures and helper functions.
public protocol AHNTextureProvider: class{
  
  
  /**
   - returns: The updated output `MTLTexture` for the `AHNTextureProvider`.
   */
  func texture() -> MTLTexture?
  
  
  
  ///- returns: The input `AHNTextureProvider` that provides the input `MTLTexture` to this `AHNTextureProvider`. If there is no input, returns `nil`.
  func textureProvider() -> AHNTextureProvider?
  
  
  
  ///- returns: A `UIImage` created from the output `MTLTexture` provided by the `texture()` function.
  func uiImage() -> UIImage?
  
  
  
  ///- returns: The MTLSize of the the output `MTLTexture`. If no size has been explicitly set, the default value returned is `128x128` pixels.
  func textureSize() -> MTLSize
  
  
  
  /**
   Updates the output `MTLTexture`.
   
   This should not need to be called manually as it is called by the `texture()` method automatically if the texture does not represent the current `AHNTextureProvider` properties.
   */
  func updateTexture()
  
  
  
  ///The `AHNContext` that is being used by the `AHNTextureProvider` to communicate with the GPU.
  var context: AHNContext {get set}
  
  
  
  ///- returns: Returns `true` if the output `MTLTexture` needs updating to represent the current `AHNTextureProvider` properties.
  func isDirty() -> Bool
  
  
  
  
  var dirty: Bool {get set}
  
  
  
  ///Returns a new `AHNTextureProvider` object.
  init()
  
  
  
  ///- returns: `True` if the object has enough inputs to provide an output.
  func canUpdate() -> Bool
  
  
  
  /**
   Returns the greyscale values in the texture for specified positions, useful for using the texture as a heightmap.
   
   - parameter positions: The 2D positions in the texture for which to return greyscale values between `0.0 - 1.0`.
   - returns: The greyscale values between `0.0 - 1.0` for the specified pixel locations.
   */
  func greyscaleValuesAtPositions(_ positions: [CGPoint]) -> [Float]
  
  
  
  /**
   Returns the colour values in the texture for specified positions.
   
   - parameter positions: The 2D positions in the texture for which to return colour values for red, green, blue and alpha between `0.0 - 1.0`.
   - returns: The colour values between `0.0 - 1.0` for the specified pixel locations.
   */
  func colourValuesAtPositions(_ positions: [CGPoint]) -> [(red: Float, green: Float, blue: Float, alpha: Float)]

  
  
  ///- returns: All points in the texture, use this as the input parameter for `colourValuesAtPositions` or `greyscaleValuesAtPositions` to return the values for the whole texture.
  func allTexturePositions() -> [CGPoint]
}












// MARK:- Default AHNTextureProvider Implementation


extension AHNTextureProvider{
  
  ///- returns: The input `AHNTextureProvider` that provides the input `MTLTexture` to this `AHNTextureProvider`. If there is no input, returns `nil`.
  public func textureProvider() -> AHNTextureProvider?{
    return nil
  }
  
  
  
  ///- returns: A UIImage created from the output `MTLTexture` provided by the `texture()` function.
  public func uiImage() -> UIImage?{
    if !canUpdate(){ return nil }
    guard let texture = texture() else { return nil }
    return UIImage.imageWithMTLTexture(texture)
  }
  
  
  
  /**
   Returns the colour values in the texture for specified positions, useful for using the texture as a heightmap.
   
   - parameter positions: The 2D positions in the texture for which to return greyscale values between `0.0 - 1.0`.
   - returns: The greyscale values between `0.0 - 1.0` for the specified pixel locations.
   */
  public func greyscaleValuesAtPositions(_ positions: [CGPoint]) -> [Float]{
    let size = textureSize()
    let pixelCount = size.width * size.height
    var array = [UInt8](repeating: 0, count: pixelCount*4)
    let region = MTLRegionMake2D(0, 0, size.width, size.height)
    texture()?.getBytes(&array, bytesPerRow: size.width * MemoryLayout<UInt8>.stride*4, from: region, mipmapLevel: 0)
    
    var returnArray = [Float](repeating: 0, count: positions.count)
    for (i, position) in positions.enumerated(){
      if Int(position.x) >= size.width || Int(position.y) >= size.height{
        print("AHNoise: ERROR - Unable to get value for \(position) as it is outside the texture bounds")
        continue
      }
      let index = (Int(position.x) + (Int(position.y) * size.width)) * 4
      returnArray[i] = Float(array[index])/255
    }
    return returnArray
  }
  
  
  
  /**
   Returns the colour values in the texture for specified positions, useful for using the texture as a heightmap.
   
   - parameter positions: The 2D positions in the texture for which to return colour values for red, green, blue and alpha between `0.0 - 1.0`.
   - returns: The colour values between `0.0 - 1.0` for the specified pixel locations.
   */
  public func colourValuesAtPositions(_ positions: [CGPoint]) -> [(red: Float, green: Float, blue: Float, alpha: Float)]{
    let size = textureSize()
    let pixelCount = size.width * size.height
    var array = [UInt8](repeating: 0, count: pixelCount*4)
    let region = MTLRegionMake2D(0, 0, size.width, size.height)
    texture()?.getBytes(&array, bytesPerRow: size.width * MemoryLayout<UInt8>.stride*4, from: region, mipmapLevel: 0)
    
    var returnArray = [(red: Float, green: Float, blue: Float, alpha: Float)](repeating: (0,0,0,0), count: positions.count)
    for (i, position) in positions.enumerated(){
      if Int(position.x) >= size.width || Int(position.y) >= size.height{
        print("AHNoise: ERROR - Unable to get value for \(position) at index \(i) as it is outside the texture bounds")
        continue
      }
      let index = (Int(position.x) + (Int(position.y) * size.width)) * 4
      let r = Float(array[index])/255
      let g = Float(array[index+1])/255
      let b = Float(array[index+2])/255
      let a = Float(array[index+3])/255
      returnArray[i] = (red: r, green: g, blue: b, alpha: a)
    }
    return returnArray
  }


  
  ///- returns: All points in the texture, use this as the input parameter for `colourValuesAtPositions` or `greyscaleValuesAtPositions` to return the values for the whole texture.
  public func allTexturePositions() -> [CGPoint]{
    let size = textureSize()
    var array: [CGPoint] = []
    for i in 0..<size.width {
      for j in 0..<size.height {
        array.append(CGPoint(x: CGFloat(j), y: CGFloat(i)))
      }
    }
    return array
  }
}

