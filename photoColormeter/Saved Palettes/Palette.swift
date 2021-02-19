//
//  Palette.swift
//  photoColormeter
//
//  Created by Robert Mukhtarov on 13.07.2020.
//  Copyright © 2020 Robert Mukhtarov. All rights reserved.
//

import Foundation
import UIKit

struct Palette: Codable {
    var name: String
    var colors: [CodableColor]
}
