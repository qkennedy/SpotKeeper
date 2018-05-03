//
//  EditMarkerViewController.swift
//  SpotKeeper
//
//  Created by Quinn Kennedy on 5/2/18.
//  Copyright © 2018 Quinn Kennedy. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class EditMarkerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryTitles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryTitles[row]
    }
    
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    var marker: Marker?
    var location: CLLocation?
    var categoryTitles: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        // Do any additional setup after loading the view.
        categoryTitles = getCategoryTitles()
        self.categoryPicker.dataSource = self
        self.categoryPicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCategories() -> [Category] {
        var categories: [Category]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            categories  = [Category]()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
            categories = try context.fetch(fetchRequest) as! [Category]
        } catch {
            print("Got an error trying to get Categories")
        }
        return categories
    }
    
    func getCategoryByTitle(title:String) -> Category {
        var categories = getCategories()
        for category in categories {
            if(category.title == title) {
                return category
            }
        }
        return categories[0]
    }
    
    func getCategoryTitles() -> [String] {
        let categories = getCategories()
        var titles: [String] = []
        for cat in categories {
            titles.append(cat.title!)
        }
        return titles
    }
    
    @IBAction func savePressed(_ sender: Any) {
        print("Creating a new marker")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let categoryTitle = categoryTitles[categoryPicker.selectedRow(inComponent: 0)]
        
        let markerEntity = NSEntityDescription.entity(forEntityName: "Marker", in: context)
        let testMarker = NSManagedObject(entity: markerEntity!, insertInto: context) as! Marker
        testMarker.setValue(titleField.text!, forKey: "title")
        testMarker.setValue(descriptionField.text!, forKey: "desc")
        testMarker.setValue(location?.coordinate.latitude, forKey: "lat")
        testMarker.setValue(location?.coordinate.longitude, forKey: "long")
        testMarker.setValue(Date(), forKey: "date_created")
        testMarker.setValue(getCategoryByTitle(title: categoryTitle), forKey: "category")
        
        do {
            try context.save()
        } catch {
            print("Failed saving Marker")
        }
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation


     }
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
