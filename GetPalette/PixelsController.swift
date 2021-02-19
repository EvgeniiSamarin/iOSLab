//
//  PixelsController.swift
//  photoColormeter
//
//  Created by Евгений Самарин on 13.07.2020.
//  Copyright © 2020 Евгений Самарин. All rights reserved.
//

import UIKit

class PixelsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var colors: [Color] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setColors(colors: [Color]) {
        self.colors = colors;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        let accountedColour: Color = colors[indexPath.row]
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2

        cell.colorPercentage?.text = accountedColour.name // + String(accountedColour.occurences) + accountedColour.hex
        
        let rgb = accountedColour.rgb;
        cell.colorBox.backgroundColor = UIColor(red: CGFloat(rgb.r) / 255 as CGFloat, green: CGFloat(rgb.g) / 255, blue: CGFloat(rgb.b) / 255, alpha: CGFloat(1))
        cell.colorBox.layer.cornerRadius = cell.colorBox.frame.height / 2

        return cell
    }
}
