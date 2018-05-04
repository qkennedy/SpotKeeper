//
//  MarkerTableViewController.swift
//  SpotKeeper
//
//  Created by Quinn Kennedy on 5/3/18.
//  Copyright © 2018 Quinn Kennedy. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class MarkerTableViewController: UITableViewController {
    
    var markers: [Marker]?
    var selectedMarker: Marker?
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList(notification:)), name: .refresh, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
                getSavedMarkers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getSavedMarkers()
    }

    func getSavedMarkers() {
        //Setup for CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Marker")
            markers = try context.fetch(fetchRequest) as? [Marker]
        } catch {
            print("Got an error trying to get markers")
        }
    }
    
    @objc func refreshList(notification: NSNotification) {
        getSavedMarkers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return markers!.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MarkerTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MarkerTableViewCell else {
            fatalError("We got a cell that isn't one of ours")
        }
        // Configure the cell...
        let marker = markers?[indexPath.row]
        cell.titleLabel.text = marker?.title
        cell.descriptionLabel.text = marker?.desc
        cell.colorSwatchView.backgroundColor = UIColor.init(hexString: (marker?.category?.color)!)
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMarker = markers![indexPath.row]
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EditMarkerSegue") {
            if let destinationViewController = segue.destination as? EditMarkerViewController {
                
                destinationViewController.marker = selectedMarker
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
