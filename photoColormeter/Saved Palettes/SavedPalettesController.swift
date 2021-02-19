//
//  SavedPalettesController.swift
//  photoColormeter
//
//  Created by Robert Mukhtarov on 13.07.2020.
//  Copyright © 2020 Robert Mukhtarov. All rights reserved.
//

import UIKit

class PaletteCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet var colorBoxes: [UIView]!
}

class SavedPalettesController: UITableViewController {
    
    var palettes: [Palette]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        if let data = UserDefaults.standard.value(forKey: "SavedPalettes") as? Data {
            palettes = try? JSONDecoder().decode([Palette].self, from: data)
        } else {
            palettes = [Palette]()
        }
        if palettes.count == 0 {
            tableView.setEmptyMessage("No Palettes")
        } else {
            navigationItem.rightBarButtonItem = editButtonItem
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return palettes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaletteCell", for: indexPath) as! PaletteCell

        let palette = palettes[indexPath.row]
        cell.name.text = palette.name
        for i in 0...5 {
            cell.colorBoxes[i].backgroundColor = palette.colors[i].color
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = palettes[sourceIndexPath.row]
        palettes.remove(at: sourceIndexPath.row)
        palettes.insert(itemToMove, at: destinationIndexPath.row)
        saveToUserDefaults()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            self.palettes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveToUserDefaults()
        }
        let editItem = UIContextualAction(style: .normal, title: "Rename") {  (contextualAction, view, boolValue) in
            self.renamePaletteAt(index: indexPath.row)
            tableView.setEditing(false, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [deleteItem, editItem])
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func renamePaletteAt(index: Int) {
        let alert = UIAlertController(title: "Rename Your Palette", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = self.palettes[index].name
        }
        let actionSave = UIAlertAction(title: "Rename", style: .default) { _ in
            var name: String! = alert.textFields?.first?.text
            name = name != "" ? name : "Untitled Palette"
            self.palettes[index].name = name
            self.tableView.reloadData()
            self.saveToUserDefaults()
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionSave)
        alert.addAction(actionCancel)
        self.present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPalette", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let palette = palettes![tableView.indexPathForSelectedRow!.row]
        let destVC = segue.destination as! PaletteController
        destVC.palette = palette
    }
    
    func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(palettes) {
            UserDefaults.standard.set(data, forKey: "SavedPalettes")
        }
    }
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.boldSystemFont(ofSize: 28.0)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
}
