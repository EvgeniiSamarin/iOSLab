//
//  CodableColor.swift
//  photoColormeter
//
//  Created by Robert Mukhtarov on 14.07.2020.
//  Copyright © 2020 Robert Mukhtarov. All rights reserved.
//

import Foundation
import UIKit

public struct CodableColor {
    let color: UIColor
}

extension CodableColor: Encodable {
    public func encode(to encoder: Encoder) throws {
        let nsCoder = NSKeyedArchiver(requiringSecureCoding: true)
        color.encode(with: nsCoder)
        var container = encoder.unkeyedContainer()
        try container.encode(nsCoder.encodedData)
    }
}

extension CodableColor: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let decodedData = try container.decode(Data.self)
        let nsCoder = try NSKeyedUnarchiver(forReadingFrom: decodedData)

        guard let color = UIColor(coder: nsCoder) else {

            struct UnexpectedlyFoundNilError: Error {}

            throw UnexpectedlyFoundNilError()
        }

        self.color = color
    }
}

public extension UIColor {
    func codable() -> CodableColor {
        return CodableColor(color: self)
    }
}
