//
//  ViewController.swift
//  SpotKeeper
//
//  Created by Quinn Kennedy on 4/30/18.
//  Copyright © 2018 Quinn Kennedy. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

class ViewController: UIViewController {
    
    // You don't need to modify the default init(nibName:bundle:) method.
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    var addedMarkers: [GMSMarker] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //Locations Init
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        //Google Maps Camera Init
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.

        let camera = GMSCameraPosition.camera(withLatitude: 41.505493,
                                              longitude: -81.681290,
                                              zoom: 12)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we&#39;ve got a location update.
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
        mapView.isHidden = true
        
        if(!hasBasicCategories()) {
            addBasicCategories()
            addDemoMarkers()
        }

        addAllSavedMarkers(mapView: mapView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.mapView.clear()
        addAllSavedMarkers(mapView: mapView)
    }
    
    
    
    func addBasicCategories() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
        let baseCategory = NSManagedObject(entity: categoryEntity!, insertInto: context) as! Category
        baseCategory.setValue("default", forKey: "title")
        baseCategory.setValue("#0000ff", forKey: "color")
        let studyCategory = NSManagedObject(entity: categoryEntity!, insertInto: context) as! Category
        studyCategory.setValue("Study Rooms", forKey: "title")
        studyCategory.setValue("#ff0000", forKey: "color")
        
        let foodCategory = NSManagedObject(entity: categoryEntity!, insertInto: context) as! Category
        foodCategory.setValue("Free Food", forKey: "title")
        foodCategory.setValue("#00ff00", forKey: "color")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func addDemoMarkers() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let studyCategory = getCategoryByTitle(title: "Study Rooms")
        
        let markerEntity = NSEntityDescription.entity(forEntityName: "Marker", in: context)
        let testMarker = NSManagedObject(entity: markerEntity!, insertInto: context) as! Marker
        testMarker.setValue("Olin 8th Floor Lab", forKey: "title")
        testMarker.setValue("Eighth Floor, Right", forKey: "desc")
        testMarker.setValue(41.502181, forKey: "lat")
        testMarker.setValue(-81.607850, forKey: "long")
        testMarker.setValue(Date(), forKey: "date_created")
        testMarker.setValue(studyCategory, forKey: "category")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
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
    
    func hasBasicCategories() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            var categories  = [Category]()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
            categories = try context.fetch(fetchRequest) as! [Category]
            return categories.count > 0
        } catch {
            print("Got an error trying to get Categories")
        }
        return false
    }
    
    func addAllSavedMarkers(mapView: GMSMapView) {
        //Setup for CoreData
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            var markers  = [Marker]()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Marker")
            markers = try context.fetch(fetchRequest) as! [Marker]
            for markerData in markers {
                print("Marker being added, I hope")
                print("coord: (lat = %f, long = %f)", markerData.lat, markerData.long)
                print("title = " + markerData.title!)
                print(markerData.lat)
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: markerData.lat, longitude: markerData.long)
                marker.title = markerData.title
                marker.snippet = markerData.desc
                marker.icon = GMSMarker.markerImage(with: UIColor.init(hexString: (markerData.category?.color)!))
                marker.map = mapView
                addedMarkers.append(marker)
            }
        } catch {
            print("Got an error trying to get markers")
        }
    }
    
    func removeMarkers() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "AddMarkerSegue") {
            currentLocation = locationManager.location
            if let destinationViewController = segue.destination as? EditMarkerViewController {
                print("current location is: ", currentLocation?.coordinate.latitude, currentLocation?.coordinate.longitude)
                destinationViewController.location = currentLocation
            }
        }

    }
    
}

extension ViewController: CLLocationManagerDelegate {

    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")

        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)

        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }

    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

