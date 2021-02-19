//
//  ConsolePrinter.swift
//  Paletter-prototype
//
//  Created by Joseph on 10.07.2020.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation

public class ConsolePrinter: ImageReaderProtocol {
    public func callback() -> Any {
        return 0
    }
    
    public func read(pixel: Pixel) {
        //print("Pixel - \(pixel.red) + \(pixel.green) + \(pixel.blue) + \(pixel.alpha)")
        
        //   print(pixel.value)
    }
}
