//
//  Database.swift
//  photoColourmeter
//
//  Created by Joseph on 13.07.2020.
//  Copyright © 2020 Евгений Самарин. All rights reserved.
//

import Foundation
import UIKit

var Colornames = NSArray()
var Map: ThreeDimensionalMap?

public struct Color {
    let name: String
    let hex: String
    let occurences: Float
    
    let rgb: (r: Int, g: Int, b: Int)
    
    init(name: String, hex: String, rgb: (r: Int, g: Int, b: Int), occurences: Float) {
        self.name = name;
        self.hex = hex;
        self.rgb = rgb;
        self.occurences = occurences;
    }
}

func LoadDatabase() {
    func loadJson(filename fileName: String) -> NSArray? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                /*
                 let decoder = JSONDecoder()
                 let jsonData = try decoder.decode([Colour].self, from: data)
                 */
                
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? NSArray {
                    // try to read out a string array
                    
                    json.forEach { (n) in
                        let dict = n as! NSMutableDictionary
                        let rgbT = hexToRgb(hexColour: dict["hex"] as! String)
                        
                        dict.setValue(rgbT, forKey: "rgb")
                    }
                    
                    Colornames = json
                    return json
                }
                
                return nil
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    
    Map = ThreeDimensionalMap(colornames: loadJson(filename: "Colournames")!)
}

func pixelToHexDistance(pixel: Pixel, hex: String) -> Int {
    let hex2Tuple = hexToRgb(hexColour: hex)
    
    let rDif = pow(Double(Int(pixel.red) - hex2Tuple.r), 2)
    let gDif = pow(Double(Int(pixel.green) - hex2Tuple.g), 2)
    let bDif = pow(Double(Int(pixel.blue) - hex2Tuple.b), 2)
    
    return Int(rDif + gDif + bDif)
}

func rgbDistance(pixel: Pixel, rgb: (r: Int, g: Int, b: Int)) -> Int32 {
    
    let rDif = pow(Double(Int(pixel.red) - rgb.r), 2)
    let gDif = pow(Double(Int(pixel.green) - rgb.g), 2)
    let bDif = pow(Double(Int(pixel.blue) - rgb.b), 2)
    
    return Int32(rDif + gDif + bDif)
}

func hexDistance(hex1: String, hex2: String) -> Int32 {
    let hex1Tuple = hexToRgb(hexColour: hex1)
    let hex2Tuple = hexToRgb(hexColour: hex2)
    
    let rDif = pow(Double(hex1Tuple.r - hex2Tuple.r), 2)
    let gDif = pow(Double(hex1Tuple.g - hex2Tuple.g), 2)
    let bDif = pow(Double(hex1Tuple.b - hex2Tuple.b), 2)
    
    return Int32(rDif + gDif + bDif)
}

func hexToRgb(hexColour: String) -> (r: Int, g: Int, b: Int) {
    var r = 0, g = 0, b = 0;
    
    let scanner = Scanner(string: hexColour)
    var hexNumber: UInt64 = 0
    
    if scanner.scanHexInt64(&hexNumber) {
        r = Int((hexNumber >> 16) & 0xFF);
        g = Int((hexNumber >> 8) & 0xFF);
        b = Int((hexNumber) & 0xFF);
    }
    
    return (r: r, g: g, b: b)
}

func getClosestColorIndex(pixel: Pixel) -> Int {
    var minimum = INT_MAX;
    var closestColourIndex = -1;
    
    loop: for i in 0..<Colornames.count {
        //let distance = hex2rgbDistance(pixel: pixel, hex: COLOURS[i].hex)
        
        let dict = Colornames[i] as! NSDictionary;
        let distance = rgbDistance(pixel: pixel, rgb: dict["rgb"] as! (r: Int, g: Int, b: Int))
        if (distance < minimum) {
            minimum = distance;
            closestColourIndex = i;
        }
        if (distance < 750){
            break loop;
        }
    }
    
    return closestColourIndex;
}


struct ThreeDimensionalMap {
    
    private static var proximity = 16;
    
    struct Dimension {
        private var dict: NSMutableDictionary
        
        init() {
            dict = NSMutableDictionary();
        }
        
        public func append(key: Int, index: Int) {
            var array = [Int]()
            
            if let _ = dict[key] {
                array = dict[key] as! [Int]
            }
            
            array.append(index)
            dict[key] = array.sorted()
        }
        
        public func getColors(key: Int) -> [Int] {
            var colorCandidates = [Int]()
            
            for i in key-proximity...key+proximity {
                if let _ = dict[i] {
                    colorCandidates = combineSortedArrays(colorCandidates, (dict[i] as! [Int]))
                }
            }
            
            return colorCandidates;
        }
        
        private func combineSortedArrays(_ arr1: [Int], _ arr2: [Int]) -> [Int]{
            var smallArray = arr1, bigArray = arr2;
            
            if (smallArray.count == 0) {
                return bigArray
            }
            
            if (smallArray.count > bigArray.count) { swap(&smallArray, &bigArray) }
            
            let smallCapacity = smallArray.count, bigCapacity = bigArray.count, totalCapacity = smallCapacity + bigCapacity;
            
            let result = UnsafeMutablePointer<Int>.allocate(capacity: totalCapacity)
            
            let small = UnsafeMutablePointer<Int>(mutating: smallArray)
            let big = UnsafeMutablePointer<Int>(mutating: bigArray)
            
            var bigP = 0, smallP = 0, resultP = 0;
            
            while resultP < (totalCapacity) {
                if (bigP < bigCapacity && smallP < smallCapacity) {
                    while (bigP < bigCapacity && smallP < smallCapacity)  {
                        if big[bigP] < small[smallP] {
                            result[resultP] = big[bigP]
                            bigP += 1
                        } else {
                            result[resultP] = small[smallP]
                            smallP += 1
                        }
                        resultP += 1;
                    }
                } else {
                    while bigP < bigCapacity {
                        result[resultP] = big[bigP]
                        bigP += 1; resultP += 1;
                    }
                    
                    while smallP < smallCapacity {
                        result[resultP] = small[smallP]
                        smallP += 1; resultP += 1;
                    }
                }
            }

            let arrayResult = Array(UnsafeBufferPointer(start: result, count: (smallArray.count + bigArray.count)));
            
            result.deallocate(); //small.deallocate(); big.deallocate();
            
            return arrayResult;
        }
    }
    
    private var dimensions = (redD: Dimension(), greenD: Dimension(), blueD: Dimension())
    
    init(colornames: NSArray) {
        for i in 0..<colornames.count {
            let dict = colornames[i] as! NSDictionary
            let rgb = dict["rgb"] as! (r: Int, g: Int, b: Int)
            
            dimensions.redD.append(key: rgb.r, index: i)
            dimensions.greenD.append(key: rgb.g, index: i)
            dimensions.blueD.append(key: rgb.b, index: i)
        }
    }
    
    private func getClosestNeighbours(pixel: Pixel) -> Int {
        ThreeDimensionalMap.proximity = 1;
        var unifiedNeighbours = self.unifyNeighbours(pixel: pixel);
        
        while (unifiedNeighbours.count == 0) {
            ThreeDimensionalMap.proximity *= 2
            unifiedNeighbours = self.unifyNeighbours(pixel: pixel)
        }
        
        var closestColorIndex: Int?
        var minimumDistance = INT_MAX
        
        unifiedNeighbours.forEach { (neighbour) in
            let dict = Colornames[neighbour] as! NSDictionary
            let rgb = dict["rgb"] as! (r: Int, g: Int, b: Int)
            let currentDistance = rgbDistance(pixel: pixel, rgb: (r: rgb.r, g: rgb.g, b: rgb.b));
            if (minimumDistance > currentDistance) {
                minimumDistance = currentDistance;
                closestColorIndex = neighbour
            }
        }
        
        //print("Closest color with distance \(minimumDistance) \(closestColor!)")
        
        return closestColorIndex!
    }
    
    private func unifyNeighbours(pixel: Pixel) -> [Int] {
        var redNeighbours: [Int] = dimensions.redD.getColors(key: Int(pixel.red))
        var greenNeighbours: [Int] = dimensions.greenD.getColors(key: Int(pixel.green))
        var blueNeighbours: [Int] = dimensions.blueD.getColors(key: Int(pixel.blue))
        
        var unifiedNeighbours = [Int]()
        
        var minimalCount = min(redNeighbours.count, greenNeighbours.count, blueNeighbours.count)
        var pointer = 0
        
        while (pointer < minimalCount) {
            let maximumValue = max(redNeighbours[pointer],  greenNeighbours[pointer], blueNeighbours[pointer])
            //var red = redNeighbours[pointer], green = greenNeighbours[pointer], blue = blueNeighbours[pointer];
            
            
            while (pointer < redNeighbours.count && redNeighbours[pointer] < maximumValue) {
                redNeighbours.remove(at: pointer)
            }
            
            while (pointer < blueNeighbours.count && blueNeighbours[pointer] < maximumValue) {
                blueNeighbours.remove(at: pointer)
            }
            
            while (pointer < greenNeighbours.count && greenNeighbours[pointer] < maximumValue) {
                greenNeighbours.remove(at: pointer)
            }
            
            minimalCount = min(redNeighbours.count, greenNeighbours.count, blueNeighbours.count)
            
            if (pointer >= minimalCount) { break; }
            
            if (greenNeighbours[pointer] == blueNeighbours[pointer] && greenNeighbours[pointer] == redNeighbours[pointer]) {
                unifiedNeighbours.append(greenNeighbours[pointer])
            }
            
            pointer += 1;
        }
        
        return unifiedNeighbours
    }
    
    public func getIndexForClosestColorname(pixel: Pixel) -> Int {
        return getClosestNeighbours(pixel: pixel)
    }
}
