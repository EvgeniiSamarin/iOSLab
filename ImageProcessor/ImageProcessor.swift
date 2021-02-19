//
//  ImageProcessor.swift
//  Paletter-prototype
//
//  Created by Joseph on 10.07.2020.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation
import UIKit

public class ImageProcessor{
    private var _oldImage : UIImage
    
    private var lookUpTable: NSMutableDictionary
    
    public var pixelCount = -1;
    
    public init(image : UIImage){
        _oldImage = image
        lookUpTable = NSMutableDictionary();
    }
    
    func countColor(pixel: Pixel, _ colorsDict: NSMutableDictionary) {
        let pixelHash = pixel.value & 0x00FFFFFF;
        
        if let match = lookUpTable[pixelHash] {
            colorsDict[match] = colorsDict[match] as! Int + 1
        } else {
            let color = Map!.getIndexForClosestColorname(pixel: pixel)
            lookUpTable[pixelHash] = color;
            
            if let _ = colorsDict[color] {
                colorsDict[color] = colorsDict[color] as! Int + 1;
            } else {
                colorsDict[color] = 1;
            }
        }
    }
    
    
    public func getStatistics() -> NSMutableDictionary {
        
        let colorsDict = NSMutableDictionary();
        
        if let _image = RGBAImage(originalImage: _oldImage) {
            self.pixelCount = (_image.height * _image.width) / 2
            
            for i in stride(from: 0, to: _image.height*_image.width, by: 2) {
                let pixel = _image.pixels[i]
                countColor(pixel: pixel, colorsDict)
            }
            lookUpTable.removeAllObjects()
            _image.pixels.deallocate()
        }
        
        return colorsDict;
        
    }
}

public func ProccessImage(image: UIImage, whenDone: @escaping (_ colors: [Color]) -> Void) {
    DispatchQueue.init(label: "Processing Image").async {
        let processor = ImageProcessor(image: image)
        let rawDictionary = processor.getStatistics();
        
        let keys = rawDictionary.keysSortedByValue {
            return ComparisonResult(rawValue: (($0 as! NSNumber).compare($1 as! NSNumber)).rawValue * -1)!
        }
        
        var colors = [Color]()
        
        for i in 0..<min(keys.count, 100) {
            let colorIndex = ((keys[i] as! Int))
            let dict = Colornames[colorIndex] as! NSDictionary
            let coverInPercentage = round((rawDictionary[keys[i]] as! Float) / Float(processor.pixelCount)*10_000) / 10_000
            
            colors.append(Color(name: dict["name"] as! String, hex: dict["hex"] as! String, rgb: dict["rgb"] as! (r: Int, g: Int, b: Int) , occurences: coverInPercentage))
        }
        
        return whenDone(colors)
    }
    
}

