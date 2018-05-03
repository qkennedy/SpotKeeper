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
    var oldTitle: String?
    var categoryTitles: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        categoryTitles = getCategoryTitles()
        self.categoryPicker.dataSource = self
        self.categoryPicker.delegate = self
        
        if(marker != nil) {
            oldTitle = marker?.title
            titleField.text = marker?.title
            descriptionField.text = marker?.desc
            let ind = getIndexOfTitle(title: (marker?.category?.title)!)
            categoryPicker.selectRow(ind, inComponent: 0, animated: true)
            location = CLLocation.init(latitude: (marker?.lat)!, longitude: (marker?.long)!)
        }
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
    
    func getIndexOfTitle(title: String) -> Int {
        var i = 0
        while(i < categoryTitles.count) {
            if(categoryTitles[i] == title) {
                return i
            }
            i += 1
        }
        return -1
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
        let title: String
        if(oldTitle != nil) {
            title = oldTitle!
        } else {
            title = titleField.text!
        }
        
        let categoryTitle = categoryTitles[categoryPicker.selectedRow(inComponent: 0)]
        
        do {
            var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Marker")
            fetchRequest.predicate = NSPredicate(format: "title = %@", title)
            if let fetchResults = try context.fetch(fetchRequest) as? [Marker] {
                if fetchResults.count != 0{
                    
                    var oldMarker = fetchResults[0]
                    oldMarker.setValue(titleField.text!, forKey: "title")
                    oldMarker.setValue(descriptionField.text!, forKey: "desc")
                    oldMarker.setValue(getCategoryByTitle(title: categoryTitle), forKey: "category")
                    

                } else {
                    let markerEntity = NSEntityDescription.entity(forEntityName: "Marker", in: context)
                    let newMarker = NSManagedObject(entity: markerEntity!, insertInto: context) as! Marker
                    newMarker.setValue(titleField.text!, forKey: "title")
                    newMarker.setValue(descriptionField.text!, forKey: "desc")
                    newMarker.setValue(location?.coordinate.latitude, forKey: "lat")
                    newMarker.setValue(location?.coordinate.longitude, forKey: "long")
                    newMarker.setValue(Date(), forKey: "date_created")
                    newMarker.setValue(getCategoryByTitle(title: categoryTitle), forKey: "category")
                    
                }
            }
        } catch {
            print("Got an error trying to get specific marker")
        }

        do {
            try context.save()
        } catch {
            print("Failed saving Marker")
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelPressed(_ sender: Any) {
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
