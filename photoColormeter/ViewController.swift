//
//  ViewController.swift
//  photoColormeter
//
//  Created by Евгений Самарин on 09.07.2020.
//  Copyright © 2020 Евгений Самарин. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet var colorBoxes: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.init(label: "Loading Database").async {
            LoadDatabase();
        }
    }
    
    @IBAction func photolibraryButton(_ sender: Any) {
        
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true) {
            //            After it is complete
        }
        
    }
    
    @IBAction func photoButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let image = UIImagePickerController()
            image.delegate = self
            
            image.sourceType = UIImagePickerController.SourceType.camera
            image.allowsEditing = false
            
            self.present(image, animated: true) {
                //                After it is complete
            }
        } else {
            print("Camera is not available")
        }
    }
    
    @IBAction func colorBoxTouched(_ sender: UIView) {
        let storyboard = UIStoryboard(name: "ColorPicker", bundle: nil)
        let colorPicker = storyboard.instantiateViewController(identifier: "colorPicker") as! ColorPickerController
        colorPicker.delegate = self
        colorPicker.colorBoxIndex = colorBoxes.firstIndex(of: sender)
        colorPicker.modalPresentationStyle = .fullScreen
        colorPicker.modalTransitionStyle = .coverVertical
        present(colorPicker, animated: true)
        colorPicker.imageView.image = myImageView.image?.resized(toWidth: 1500.0)
    }
    
    @IBAction func transferToTableView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "PaletteAlgorithmStoryboard", bundle: nil)
        let view = storyboard.instantiateViewController(identifier: "PixelsController") as! PixelsController
        
        if let image = self.myImageView.image  {
            ProccessImage(image: image, whenDone: {
                (colors: [Color]) in
                view.setColors(colors: colors)
                DispatchQueue.main.sync {
                    //self.navigationController?.pushViewController(view, animated: true)
                    for i in 0..<self.colorBoxes.count {
                        let rgb = colors[i].rgb;
                        
                        self.colorBoxes[i].backgroundColor! = UIColor(red: CGFloat(rgb.r) / 255.0, green: CGFloat(rgb.g) / 255.0, blue: CGFloat(rgb.b) / 255.0, alpha: 1)
                        //.colors.append(box.backgroundColor?.codable() ?? UIColor.black.codable())
                    }
                    
                    self.present(view, animated: true)
                }
            });
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myImageView.image = image
        } else {
            //            Error message here
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showSavedPalettes(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SavedPalettes", bundle: nil)
        let savedPalettes = storyboard.instantiateViewController(identifier: "navigationController") as! SavedPalettesNavigationController
        savedPalettes.modalPresentationStyle = .fullScreen
        savedPalettes.modalTransitionStyle = .flipHorizontal
        present(savedPalettes, animated: true)
    }

    @IBAction func savePalette(_ sender: Any) {
        let alert = UIAlertController(title: "Name Your Palette", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        let actionSave = UIAlertAction(title: "Save", style: .default) { _ in
            var name: String! = alert.textFields?.first?.text
            name = name != "" ? name : "Untitled Palette"
            var palette = Palette(name: name, colors: [CodableColor]())
            for box in self.colorBoxes {
                palette.colors.append(box.backgroundColor?.codable() ?? UIColor.black.codable())
            }
            var palettes: [Palette]!
            if let data = UserDefaults.standard.value(forKey: "SavedPalettes") as? Data {
                palettes = try? JSONDecoder().decode([Palette].self, from: data)
            } else {
                palettes = [Palette]()
            }
            palettes.append(palette)
            if let data = try? JSONEncoder().encode(palettes) {
                UserDefaults.standard.set(data, forKey: "SavedPalettes")
            }
            self.showMessage("Added to Palette Library", seconds: 1.0)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionSave)
        alert.addAction(actionCancel)
        self.present(alert, animated: true)
    }
}

extension UIViewController {
    func showMessage(_ message: String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        alert.view.layer.cornerRadius = 15
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}
