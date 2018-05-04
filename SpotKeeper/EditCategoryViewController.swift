
import UIKit
import GoogleMaps
import CoreData

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    func isValidHexColor() -> Bool {
        //Make sure it has a hash on the front, and 6 characters
        if(!self.isEmpty) {
            if(self[0] == "#" && self.count == 7){
                //Make sure the characters are valid
                let chars = CharacterSet(charactersIn: "#0123456789ABCDEF")
                guard uppercased().rangeOfCharacter(from: chars) != nil else {
                    return false
                }
                return true
            }
        }
        return false
    }
}

class EditCategoryViewController: UIViewController{
    
    var category: Category?
    var oldTitle: String?
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var colorHexField: UITextField!
    @IBOutlet weak var colorSwatchView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if(category != nil) {
            oldTitle = category?.title
            titleField.text = category?.title
            colorHexField.text = category?.color
            updateColorSwatch(colorString: (category?.color)!)
        } else {
            colorHexField.text = "#0000FF"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateColorSwatch(colorString: String) {
        if(colorString.isValidHexColor()) {
            colorSwatchView.backgroundColor = UIColor.init(hexString: colorString)
        }
    }
    
    @IBAction func colorHexValChanged(_ sender: Any) {
        let colorStr = colorHexField.text!
        if(colorStr.isValidHexColor()) {
            saveButton.isEnabled = true
            updateColorSwatch(colorString: colorStr)
        } else {
            saveButton.isEnabled = false;
        }
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
        
        do {
            var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
            fetchRequest.predicate = NSPredicate(format: "title = %@", title)
            if let fetchResults = try context.fetch(fetchRequest) as? [Category] {
                if fetchResults.count != 0{
                    var oldCategory = fetchResults[0]
                    oldCategory.setValue(titleField.text!, forKey: "title")
                    oldCategory.setValue(colorHexField.text!, forKey: "color")
                } else {
                    let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
                    let newCategory = NSManagedObject(entity: categoryEntity!, insertInto: context) as! Category
                    newCategory.setValue(titleField.text!, forKey: "title")
                    newCategory.setValue(colorHexField.text!, forKey: "color")
                }
            }
        } catch {
            print("Got an error trying to get specific category")
        }
        
        do {
            try context.save()
        } catch {
            print("Failed saving Category")
        }
        performSegue(withIdentifier: "unwindSegueToFirstVC", sender: self)
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
