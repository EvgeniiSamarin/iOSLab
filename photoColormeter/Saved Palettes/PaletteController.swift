//
//  PaletteController.swift
//  photoColormeter
//
//  Created by Robert Mukhtarov on 16.07.2020.
//  Copyright © 2020 Robert Mukhtarov. All rights reserved.
//

import UIKit

class ColorCell: UITableViewCell {
    @IBOutlet weak var colorBox: UIView!
    @IBOutlet weak var hexValueLabel: UILabel!
    @IBOutlet weak var rgbValueLabel: UILabel!
}

class PaletteController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var palette: Palette!
    @IBOutlet weak var paletteView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        titleLabel.text = palette.name
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        palette.colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorCell
        let color = palette.colors[indexPath.row].color
        cell.colorBox.backgroundColor = color
        cell.hexValueLabel.text = color.HEXValue
        let rgb = color.RGBValues
        cell.rgbValueLabel.text = "\(rgb.r), \(rgb.g), \(rgb.b)"
        return cell
    }
    
    @IBAction func share(_ sender: Any) {
        let image = paletteView.asImage()
        let alert = UIAlertController(title: "Export Palette", message: "Select what you would like to do with this palette.", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Share as Image", style: .default , handler:{ (UIAlertAction)in
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
            self.present(vc, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Save to Photos", style: .default , handler:{ (UIAlertAction) in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.savedImage), nil);
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        self.present(alert, animated: true)
    }
    
    @objc func savedImage(_ im: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
        if error != nil {
            showMessage("We need your permission to save images.", seconds: 1.5)
            return
        }
        showMessage("Saved to Photos", seconds: 1.0)
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
