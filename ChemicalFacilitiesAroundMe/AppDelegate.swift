//
//  AppDelegate.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 9/28/20.
//

import UIKit
import CoreData
import IQKeyboardManager
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        preloadData()
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        GMSPlacesClient.provideAPIKey("AIzaSyDltyRQPHZu7R-K86F65vj-N1YaW7p3YB8")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ChemicalFacilitiesAroundMe")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    func preloadData() {
        let context = persistentContainer.viewContext
        let preloadDataKey = "didPreloadData"
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: preloadDataKey) == false {
            if let urlPath = Bundle.main.url(forResource: "Facility", withExtension: "csv") {
                if let items = processData(contentsOfURL: urlPath, encoding: .utf8) {
                    for item in items {
                        let facilityItem = FacilityItem(context: context)
                        facilityItem.city = item.city
                        facilityItem.classification = item.classification
                        facilityItem.facilityDescription = item.facilityDescription
                        facilityItem.facilityName = item.facilityName
                        facilityItem.latitude = item.latitude
                        facilityItem.longitude = item.longitude
                        facilityItem.address = item.address
                        facilityItem.zipCode = item.zipCode
                    }
                }
            }
            userDefaults.setValue(true, forKey: preloadDataKey)
            self.saveContext()
        }
    }
    
    func removeData() {
        let context = persistentContainer.viewContext
        do {
            let request = FacilityItem.fetchRequest() as NSFetchRequest<FacilityItem>
            let facilityItems = try context.fetch(request)
            for facilityItem in facilityItems {
                context.delete(facilityItem)
            }
            self.saveContext()
        } catch {
            print("Failed to delete all preloaded facilities, \(error.localizedDescription)")
        }
    }
    
    func processData(contentsOfURL: URL, encoding: String.Encoding) -> [(facilityName: String, address: String, city: String, zipCode: String, latitude: Double, longitude: Double, classification: String, facilityDescription: String)]? {
        
            let delimiter = ","
            var items = [(facilityName: String, address: String, city: String, zipCode: String, latitude: Double, longitude: Double, classification: String, facilityDescription: String)]()
            do {
                removeData()
                let content = try String(contentsOf: contentsOfURL, encoding: encoding)
                let lines = content.components(separatedBy: "\n")
                for line in lines {
                    var values = [String]()
                    if line != "" {
                        values = line.components(separatedBy: delimiter)
                        let item = (facilityName: values[0], address: values[1], city: values[2], zipCode: values[3], latitude: Double(values[4])!, longitude: Double(values[5])!, classification: values[6], facilityDescription: values[7])
                        items.append(item)
                    }
                }
            } catch {
                fatalError("Failed to remove the data and preload the data, \(error.localizedDescription)")
            }
            return items
        }

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

