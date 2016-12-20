//
//  AHNGeneratorCoherent.swift
//  AHNoise
//
//  Created by Andrew Heard on 22/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//


import UIKit
import Metal
import simd



///Struct used to communicate properties to the GPU.
struct CoherentInputs {
  var pos: vector_float2
  var rotations: vector_float3
  var octaves: Int32
  var persistence: Float
  var frequency: Float
  var lacunarity: Float
  var zValue: Float
  var wValue: Float
  var offsetStrength: Float
  var use4D: Int32
  var sphereMap: Int32
  var seamless: Int32
}


/**
 The general class to generate cohesive noise outputs. This class is not instantiated directly, but is used by various subclasses.
 
 The output texture represents a 2D slice through a 3D geometric or noise function that can optionally be distorted in the x and y axes.
 
 *Conforms to the `AHNTextureProvider` protocol.*
 */
open class AHNGeneratorCoherent: AHNGenerator {
  
  
  // MARK:- Properties
  
  
  ///When `true`, the simplex kernel used has four degrees of freedom, which allows for interesting seamless patterns but has extra computational cost. This has no effect for the `AHNGeneratorVoronoi`, which is always calculated in 4 dimensions. The default value is `false`.
  open var use4D: Bool = false{
    didSet{
      dirty = true
    }
  }
  
  
  ///When `true`, the output texture is warped towards the top and bottom to seamless map to a UV sphere. When `true` the `zValue` and `wValue` properties have no effect as they are overridden in the shader to produce the sphere mapped effect. The default value is `false`.
  open var sphereMap: Bool = false{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///When `true`, the output texture can be seamlessly tiled without apparent edges showing. When `true` the `zValue` and `wValue` properties have no effect as they are overridden in the shader to produce the seamless effect. The default value is `false`.
  open var seamless: Bool = false{
    didSet{
      dirty = true
    }
  }
  
  
  
  /**
   The number of `octaves` to use in the texture. Each `octave` is calculated with a different amplitude (altered by the `persistence` property) and `frequency` (altered by the `lacunarity` property). The amplitude starts with a value of `1.0`, the first octave is calculated using this value, the amplitude is then multiplied by the `persistence` and the next octave is calculated using this new amplitude before multiplying it again by the `persistence` and so on. The `frequency` follows a similar pattern with the `lacunarity` property.
   
   Each `octave` is calculated and then combined to produce the final value.
   
   Higher values (`12`) produce more detailed noise, where as lower values produce smoother noise. Higher values have a performance impact.
   
   The default value is `6`.
   */
  open var octaves: Int = 6{
    didSet{
      dirty = true
    }
  }
  
  
  
  /**
   Varies the amplitude every octave. The amplitude is multiplied by the `persistence` for each octave. Generally values less than 1.0 are used.
   
   For example an initial amplitude of `1.0` (fixed) and a `persistence` of `0.5` for `4` octaves would produce an amplitude of `1.0`, `0.5`, `0.25` and `0.125` respectively for each octave.
   
   The default value is `0.5`.
   */
  open var persistence: Float = 0.5{
    didSet{
      dirty = true
    }
  }
  
  
  
  /**
   The frequency used when calculating the noise. Higher values produce more dense noise.
   
   The `frequency` is multiplied by the `lacunarity` property each octave.
   
   The default value is `1.0`.
   */
  open var frequency: Float = 1.0{
    didSet{
      dirty = true
    }
  }
  
  
  
  /**
   Varies the `frequency` every octave. The `frequency` is multiplied by the `lacunarity` for each octave. Generally values greater than `1.0` are used.
   
   For example an initial `frequency` of `1.0` and a `lacunarity` of `2.0` for `4` octaves would produce a `frequency` of `1.0`, `2.0`, `4.0` and `8.0` respectively for each octave.
   
   The default value is `2.0`.
   */
  open var lacunarity: Float = 2.0{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The origin of the noise along the x axis in noise space. Changing this slightly will make the noise texture appear to move.
  ///
  ///The default value is `1.0`.
  open var xValue: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The origin of the noise along the y axis in noise space. Changing this slightly will make the noise texture appear to move.
  ///
  ///The default value is `1.0`.
  open var yValue: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The value for the third dimension when calculating the noise. Changing this slightly will make the noise texture appear to animate.
  ///
  ///Default is `1.0`.
  open var zValue: Float = 1{
    didSet{
      dirty = true
    }
  }
  
  
  
  ///The value for the fourth dimension when calculating the noise. Changing this slightly will make the noise texture appear to animate.
  ///
  ///Default is `1.0`.
  open var wValue: Float = 1{
    didSet{
      dirty = true
    }
  }

  
  
  
  
  
  
  
  
  
  // MARK:- Initialiser
  
  
  /**
   Creates a new `AHNGeneratorCoherent` object.
   
   To be called when instantiating a subclass.
   
   - parameter functionName: The name of the kernel function that this this generator will use to create an output.
   */
  public override init(functionName: String){
    super.init(functionName: functionName)
  }
  
  
  
  public required init() {
    super.init()
  }
  
  
  
  
  
  
  
  
  // MARK:- Array buffer binding
  open override func configureArgumentTableWithCommandencoder(_ commandEncoder: MTLComputeCommandEncoder) {
    commandEncoder.setBuffer(context.grad3Buffer, offset: 0, at: 0)
    commandEncoder.setBuffer(context.grad4Buffer, offset: 0, at: 1)
    commandEncoder.setBuffer(context.permBuffer, offset: 0, at: 2)
    commandEncoder.setBuffer(context.permMod12Buffer, offset: 0, at: 3)
  }
}
