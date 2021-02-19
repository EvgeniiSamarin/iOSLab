//
//  ColorPickerController.swift
//  photoColormeter
//
//  Created by Robert Mukhtarov on 10.07.2020.
//  Copyright © 2020 Robert Mukhtarov. All rights reserved.
//

import UIKit

class ColorPickerController: UIViewController {

    weak var delegate: ViewController!
    var colorBoxIndex: Int!
    @IBOutlet weak var screenView: UIView!
    @IBOutlet weak var hexLabel: UILabel!
    @IBOutlet weak var rgbLabel: UILabel!
    @IBOutlet weak var colorBox: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var circle: CAShapeLayer!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        drawCircle()
        detectColor(at: screenView.center)
    }

    @IBAction func useColor(_ sender: Any) {
        delegate.colorBoxes[colorBoxIndex].backgroundColor = colorBox.backgroundColor
        dismiss(animated: true)
    }
    
  
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }

    func detectColor(at point: CGPoint) {
        let color = screenView.colorAt(point: point)
        colorBox.backgroundColor = color
        let rgb = color.RGBValues
        rgbLabel.text = "\(rgb.r), \(rgb.g), \(rgb.b)"
        hexLabel.text = color.HEXValue
        circle.position = point
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        if let point = touch?.location(in: view) {
            detectColor(at: point)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch = touches.first
        if let point = touch?.location(in: view) {
            CALayer.performWithoutAnimation {
                detectColor(at: point)
            }
        }
    }

    func drawCircle() {
        let circlePath = UIBezierPath(arcCenter: CGPoint.zero, radius: 8, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circle = CAShapeLayer()
        circle.path = circlePath.cgPath
        circle.fillColor = .none
        circle.strokeColor = UIColor.white.cgColor
        circle.lineWidth = 3
        circle.position = screenView.center
        view.layer.addSublayer(circle)
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r, g, b, a)
        }
        return (0, 0, 0, 0)
    }

    var RGBValues: (r: Int, g: Int, b: Int) {
        return (Int(rgba.red * 255.0), Int(rgba.green * 255.0), Int(rgba.blue * 255.0))
    }

    var HEXValue: String {
        return String(format: "#%02x%02x%02x", Int(rgba.red * 255.0), Int(rgba.green * 255.0), Int(rgba.blue * 255.0)).uppercased()
    }
}

extension CALayer {
    // Нужно, чтобы окружность двигалась без задержки, когда пользователь водит пальцем по экрану
    class func performWithoutAnimation(_ actionsWithoutAnimation: () -> Void) {
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        actionsWithoutAnimation()
        CATransaction.commit()
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIView {

    func colorAt(point: CGPoint) -> UIColor {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        var pixelData: [UInt8] = [0, 0, 0, 0]

        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        context!.translateBy(x: -point.x, y: -point.y)

        self.layer.render(in: context!)

        let red: CGFloat = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green: CGFloat = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue: CGFloat = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha: CGFloat = CGFloat(pixelData[3]) / CGFloat(255.0)

        let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)

        return color
    }
}
