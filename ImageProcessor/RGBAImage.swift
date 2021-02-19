//
//  RGBA_Image.swift
//  Paletter-prototype
//
//  Created by Joseph on 10.07.2020.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit

public struct Pixel {
    public var value: UInt32
    
    public var red: UInt8 {
        get {
            return UInt8(value & 0xFF)
        }
        set {
            value = UInt32(newValue) | (value & 0xFFFFFF00)
        }
    }
    
    public var green: UInt8 {
        get {
            return UInt8((value >> 8) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
        }
    }
    
    public var blue: UInt8 {
        get {
            return UInt8((value >> 16) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
        }
    }
    
    public var alpha: UInt8 {
        get {
            return UInt8((value >> 24) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
        }
    }
    
    public func toHexString() -> String {
        return String(format:"%02X", red) + String(format:"%02X", green) + String(format:"%02X", blue);
    }
}

public class RGBAImage {
    public var pixels: UnsafeMutablePointer<Pixel>
    
    public var width: Int
    public var height: Int
    
    public init?(originalImage: UIImage) {
        
        let image = originalImage.resizeWithScaleAspectFitMode(to: 100)
        //let image = originalImage.resize(to: CGSize(width: 500.0, height: 500), with: .accelerate)
       // let image = originalImage
        guard let cgImage = image?.cgImage else { return nil }
        
        let colorSpace = cgImage.colorSpace!
        
        let bitmapInfo = cgImage.bitmapInfo.rawValue
        //bitmapInfo = cgImage.bitmapInfo.rawValue
        
        width = Int(image!.size.width)
        height = Int(image!.size.height)
        
        let bytesPerRow = cgImage.bytesPerRow
        let bitsPerComponent = cgImage.bitsPerComponent
        
        pixels = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        
        guard let imageContext = CGContext(data: pixels, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            pixels.deallocate()
            return nil
        }
        
        imageContext.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height)))
    }
}

