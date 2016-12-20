//
//  UIImage+AHNoise.swift
//  AHNoise
//
//  Created by Andrew Heard on 23/02/2016.
//  Copyright © 2016 Andrew Heard. All rights reserved.
//

import UIKit


extension UIImage{
  
  ///Converts the input `MTLTexture` into a UIImage.
  static func imageWithMTLTexture(_ texture: MTLTexture) -> UIImage{
    assert(texture.pixelFormat == .rgba8Unorm, "Pixel format of texture must be MTLPixelFormatBGRA8Unorm to create UIImage")
    
    let imageByteCount: size_t = texture.width * texture.height * 4
    let imageBytes = malloc(imageByteCount)
    let bytesPerRow = texture.width * 4
    
    let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
    texture.getBytes(imageBytes!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
    
    let AHNReleaseDataCallback: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
      free(UnsafeMutableRawPointer(mutating: data))
    }
    
    guard let provider = CGDataProvider(dataInfo: nil, data: imageBytes!, size: imageByteCount, releaseData: AHNReleaseDataCallback) else {
      fatalError("AHNoise: Error creating CGDataProvider for conversion of MTLTexture to UIImage")
    }
    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let colourSpaceRef = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), CGBitmapInfo.byteOrder32Big]
    let renderingIntent: CGColorRenderingIntent = .defaultIntent
    
    let imageRef = CGImage(
      width: texture.width,
      height: texture.height,
      bitsPerComponent: bitsPerComponent,
      bitsPerPixel: bitsPerPixel,
      bytesPerRow: bytesPerRow,
      space: colourSpaceRef,
      bitmapInfo: bitmapInfo,
      provider: provider,
      decode: nil,
      shouldInterpolate: false,
      intent: renderingIntent)
    
    let image = UIImage(cgImage: imageRef!, scale: 0.0, orientation: UIImageOrientation.downMirrored)
    return image
  }
}
