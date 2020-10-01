//
//  AppDelegate.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 9/28/20.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        print("this line is run")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        print("this line is run")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        print("this line is run")
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
                if let items = processData(contentsOfURL: urlPath, encoding: String.Encoding.utf8) {
                    for item in items {
                        let facilityItem = NSEntityDescription.insertNewObject(forEntityName: "FacilityItem", into: context) as! FacilityItem
                        
                        
                        facilityItem.city = item.city
                        facilityItem.classification = item.classification
                        facilityItem.county = item.county
                        facilityItem.facilityDescription = item.facilityDescription
                        facilityItem.facilityName = item.facilityName
                        facilityItem.latitude = item.latitude
                        facilityItem.longitude = item.longitude
                        facilityItem.operationStatus = item.operationStatus
                        facilityItem.streetAddress = item.streetAddress
                        facilityItem.zipCode = item.zipCode
                        
                    }
                }
            }
            userDefaults.setValue(true, forKey: preloadDataKey)
            do {
                try context.save()
            } catch {
                fatalError()
            }
            
        }
    }
    
    func removeData() {
        let context = persistentContainer.viewContext
        //let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FacilityItem")
        
        do {
            let request = FacilityItem.fetchRequest() as NSFetchRequest<FacilityItem>
            let facilityItems = try context.fetch(request)
            for facilityItem in facilityItems {
                context.delete(facilityItem)
            }
        } catch {
            print("Failed to retrieve records")
        }
    }
    
    func processData(contentsOfURL: URL, encoding: String.Encoding) -> [(facilityName: String, streetAddress: String, city: String, zipCode: String, latitude: Double, longitude: Double, county: String, operationStatus: String, classification: String, facilityDescription: String)]? {

        let delimiter = ","
        var items: [(facilityName: String, streetAddress: String, city: String, zipCode: String, latitude: Double, longitude: Double, county: String, operationStatus: String, classification: String, facilityDescription: String)]
        do {
            let content = try String(contentsOf: contentsOfURL, encoding: encoding)
            items = []
            let lines: [String] = content.components(separatedBy: .newlines) as [String]
            
            for line in lines {
                var values: [String] = []
                if line != "" {
                    if line.range(of: "\"") != nil {
                        var textToScan: String = line
                        var value = ""
                        var textScanner: Scanner = Scanner(string: textToScan)
                        while textScanner.string != "" {
                            if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)
                                value += textScanner.scanUpToString("\"")!
                                textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)
                            } else {
                                value += textScanner.scanUpToString(delimiter)!
                            }
                            values.append(value)
                            
                            if !textScanner.isAtEnd {
                                textToScan = String((textScanner.string)[textScanner.currentIndex...])
                            } else {
                                textToScan = ""
                            }
                            textScanner = Scanner(string: textToScan)
                        }
                        
                    } else {
                        values = line.components(separatedBy: delimiter)
                    }
                    
                    let item = (facilityName: values[0], streetAddress: values[1], city: values[2], zipCode: values[3],
                                latitude: Double(values[4])!, longitude: Double(values[5])!, county: values[6], operationStatus: values[7],
                                classification: values[8], facilityDescription: values[9])
                    items.append(item)
                }
            }
        } catch {
            fatalError()
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

