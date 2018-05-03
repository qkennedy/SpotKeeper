//
//  CategoryTableViewController.swift
//  SpotKeeper
//
//  Created by Quinn Kennedy on 5/3/18.
//  Copyright © 2018 Quinn Kennedy. All rights reserved.
//


import UIKit
import GoogleMaps
import CoreData

extension Notification.Name {
    static let peru = Notification.Name("peru")
    static let argentina = Notification.Name("argentina")
}

class CategoryTableViewController: UITableViewController {
    
    var categories: [Category]?
    var selectedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshList(notification:)), name: .refresh, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        getCategories()
    }
    
    func refreshList(notification: NSNotification) {
        getCategories()
    }
    override func viewDidAppear(_ animated: Bool) {
        getCategories()
    }
    
    func getCategories() {
        //Setup for CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
            categories = try context.fetch(fetchRequest) as? [Category]
        } catch {
            print("Got an error trying to get markers")
        }
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
        return categories!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CategoryTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CategoryTableViewCell else {
            fatalError("We got a cell that isn't one of ours")
        }
        // Configure the cell...
        let category = categories?[indexPath.row]
        cell.categoryTitle.text = category?.title
        cell.colorSwatchView.backgroundColor = UIColor.init(hexString: (category?.color)!)
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func getCategoryByTitle(title:String) -> Category {
        for category in categories! {
            if(category.title == title) {
                return category
            }
        }
        return categories![0]
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let sendCell = sender as? CategoryTableViewCell {
                let category = getCategoryByTitle(title: sendCell.categoryTitle!.text!)
            if(segue.identifier == "EditCategorySegue") {
                if let destinationViewController = segue.destination as? EditCategoryViewController {
                    
                    destinationViewController.category = category
                }
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

