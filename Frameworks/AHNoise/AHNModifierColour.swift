//
//  AHNModifierColour.swift
//  AHNoise
//
//  Created by Andrew Heard on 26/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import UIKit
import Metal
import simd


/**
 Takes the outputs of any class that adheres to the `AHNTextureProvider` protocol and colourises it.
 
 Applies a colouring to a specific range of values in a texture. Each `colour` has a position and an intensity dictating which values in the input texture are colourised and by how much. Colours and intensities are interpolated between positions.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNModifierColour: AHNModifier {

  
  // MARK:- Properties
  
  
  ///A buffer to contain colour positions.
  var positionBuffer: MTLBuffer?
  
  
  
  ///A buffer to contain the number of colours to use.
  var countBuffer: MTLBuffer?
  
  
  
  ///A buffer to contain the intensities of the colour application.
  var intensityBuffer: MTLBuffer?
  
  
  
  ///A boolean to detect whether or not default colours are being used to avoid a crash
  var defaultsUsed: Bool = false
  
  
  
  ///The number of colours in use
  var colourCount: Int32{
    get{
      return Int32(_colours.count)
    }
  }
  
  
  
  ///The colour to apply to the input. Do not set directly, use the `colours` property.
  fileprivate var _colours: [UIColor] = []{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The central position of the colouring range. Pixels with this value in the texture will output the `colour` due to a mix value of 1.0. Do not set directly, use the `colours` property. Default value is 0.5.
  fileprivate var _positions: [Float] = []{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The intensities with which to apply the colours to in input. Do not set directly, use the `colours` property.
  fileprivate var _intensities: [Float] = []{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The colour to apply to the input, with associated positions and intensities.
  open var colours: [(colour: UIColor, position: Float, intensity: Float)]{
    get{
      var tuples: [(colour: UIColor, position: Float, intensity: Float)] = []
      for (i, colour) in _colours.enumerated(){
        let tuple = (colour, _positions[i], _intensities[i])
        tuples.append(tuple)
      }
      return tuples
    }
    set{
      var newValue = newValue
      defaultsUsed = false
      if newValue.count == 0{
        newValue = [(UIColor.white, 0.5, 0.0)]
        defaultsUsed = true
      }
      var colours: [UIColor] = []
      var positions: [Float] = []
      var intensities: [Float] = []
      for tuple in newValue{
        colours.append(tuple.colour)
        positions.append(tuple.position)
        intensities.append(tuple.intensity)
      }
      _colours = colours
      _positions = positions
      _intensities = intensities
      dirty = true
      organiseColoursInOrder()
    }
  }
  
  

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  required public init(){
    super.init(functionName: "colourModifier")
    colours = []
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK:- Argument table update
  
  
  ///Encodes the required uniform values for this `AHNModifier` subclass. This should never be called directly.
  open override func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    assert(_positions.count == _colours.count && _colours.count == _intensities.count, "AHNoise: ERROR - Number of colours to use must match the number of positions and intensities.")
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    // Convert UIColours to vector_float4
    var uniformsColours: [vector_float4] = []
    for colour in _colours{
      colour.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
      uniformsColours.append(vector_float4(Float(red), Float(green), Float(blue), Float(alpha)))
    }
    
    // Create colour buffer and copy data
    var bufferSize = MemoryLayout<vector_float4>.stride * _colours.count
    if uniformBuffer == nil || uniformBuffer?.length != bufferSize{
      uniformBuffer = context.device.makeBuffer(length: bufferSize, options: MTLResourceOptions())
    }
    memcpy(uniformBuffer!.contents(), &uniformsColours, bufferSize)
    commandEncoder.setBuffer(uniformBuffer, offset: 0, at: 0)
    
    // Create positions buffer and copy data
    bufferSize = MemoryLayout<Float>.stride * _positions.count
    if positionBuffer == nil || positionBuffer?.length != bufferSize{
      positionBuffer = context.device.makeBuffer(length: bufferSize, options: MTLResourceOptions())
    }
    memcpy(positionBuffer!.contents(), &_positions, bufferSize)
    commandEncoder.setBuffer(positionBuffer, offset: 0, at: 1)
    
    // Create intensities buffer and copy data
    bufferSize = MemoryLayout<Float>.stride * _intensities.count
    if intensityBuffer == nil || intensityBuffer?.length != bufferSize{
      intensityBuffer = context.device.makeBuffer(length: bufferSize, options: MTLResourceOptions())
    }
    memcpy(intensityBuffer!.contents(), &_intensities, bufferSize)
    commandEncoder.setBuffer(intensityBuffer, offset: 0, at: 2)
    
    // Create the colour count buffer and copy data
    bufferSize = MemoryLayout<Float>.stride
    if countBuffer == nil{
      countBuffer = context.device.makeBuffer(length: bufferSize, options: MTLResourceOptions())
    }
    var count = colourCount
    memcpy(countBuffer!.contents(), &count, bufferSize)
    commandEncoder.setBuffer(countBuffer, offset: 0, at: 3)
  }








  // MARK:- Colour Handling
  
  
  ///Organise the colours, positions and intensities arrays.
  fileprivate func organiseColoursInOrder(){
    assert(_positions.count == _colours.count && _colours.count == _intensities.count, "AHNoise: ERROR - Number of colours to use must match the number of positions and intensities.")
    var tuples: [(colour: UIColor, position: Float, intensity: Float)] = []
    
    for (i, colour) in _colours.enumerated(){
      let tuple = (colour, _positions[i], _intensities[i])
      tuples.append(tuple)
    }
    
    tuples = tuples.sorted(by: { $0.position < $1.position })
    
    var sortedColours: [UIColor] = []
    var sortedPositions: [Float] = []
    var sortedIntensities: [Float] = []
    for tuple in tuples{
      sortedColours.append(tuple.colour)
      sortedPositions.append(tuple.position)
      sortedIntensities.append(tuple.intensity)
    }
    
    _colours = sortedColours
    _positions = sortedPositions
    _intensities = sortedIntensities
  }
  
  
  ///Add a new colour, with corresponding position and intensity.
  open func addColour(_ colour: UIColor, position: Float, intensity: Float){
    if defaultsUsed{
      colours = [(colour, position, intensity)]
    }else{
      colours.append((colour, position, intensity))
    }
  }
  
  
  
  ///Remove all colours.
  open func removeAllColours(){
    colours = []
  }
}
