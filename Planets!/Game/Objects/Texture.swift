//
//  Texture.swift
//  Planets!
//
//  Created by Robert-Hein Hooijmans on 09/12/16.
//  Copyright © 2016 Robert-Hein Hooijmans. All rights reserved.
//

import Foundation
import UIKit

typealias TextureProgress = ((Float) -> Void)
typealias TextureClosure = (Texture) -> Void

struct Texture {
    let color: UIColor
    let diffuse: UIImage
    let metalness: UIImage
    let normal: UIImage
    
    init(_ color: UIColor, _ diffuse: UIImage, _ metalness: UIImage, _ normal: UIImage) {
        self.color = color
        self.diffuse = diffuse
        self.metalness = metalness
        self.normal = normal
    }
    
    static func generate(for color: UIColor, progress: @escaping TextureProgress, completion: @escaping TextureClosure) {
        progress(0.1)
        
        DispatchQueue(label: "queue", qos: .userInitiated).async {
            let textureSize = 512
            
            let generator = Generator.random().object()
            generator.textureWidth = textureSize
            generator.textureHeight = textureSize
            generator.octaves = 1
            generator.frequency = Float.random() * 6 + 1
            generator.persistence = Float.random()
            generator.lacunarity = Float.random() * 10
            generator.sphereMap = true
            
            let colorConstant = AHNGeneratorConstant()
            colorConstant.textureWidth = textureSize
            colorConstant.textureHeight = textureSize
            colorConstant.red = Float(color.red())
            colorConstant.green = Float(color.green())
            colorConstant.blue = Float(color.blue())
            
            let combiner = Combiner.random().object()
            combiner.provider = colorConstant
            combiner.provider2 = generator
            
            let modifier = AHNModifierMapNormal()
            modifier.provider = generator
            modifier.intensity = 3
            modifier.smoothing = 0
            
            DispatchQueue.main.async { progress(0.25) }
            
            let metalness = generator.uiImage()
            DispatchQueue.main.async { progress(0.5) }
            
            let diffuse = combiner.uiImage()
            DispatchQueue.main.async { progress(0.75) }
            
            let normal = modifier.uiImage()
            
            DispatchQueue.main.async { completion(Texture(color, diffuse!, metalness!, normal!)) }
        }
    }
}
