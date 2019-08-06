//
//  AppDelegate.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import UIKit
import CoreData
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        for fontFamilyName in UIFont.familyNames{
            for fontName in UIFont.fontNames(forFamilyName: fontFamilyName){
                print("Family: \(fontFamilyName)     Font: \(fontName)")
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
       
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
      
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    

    func applicationWillTerminate(_ application: UIApplication) {
      
        self.saveContext()
    }
    
    /// Default placeholder function
    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    /// Default pandle load GPX file
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("load gpx File: \(url.absoluteString)")
        let fileManager = FileManager.default
        do {
            try fileManager.moveItem(at: url, to: GPXFileManager.GPXFilesFolderURL.appendingPathComponent(url.lastPathComponent))
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
       
        
         NotificationCenter.default.post(name: .didReceiveFileFromURL, object: nil)
        return true
    }
    
    // MARK: - Core Data stack
    
    /// Default placeholder function
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    /// Default placeholder function
    lazy var managedObjectModel: NSManagedObjectModel = {
       
        let modelURL = Bundle.main.url(forResource: "TrackLocation", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    /// Default placeholder function
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
       
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("location_tracker.sqlite")
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
           
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "ERROR", code: 9999, userInfo: dict)
           
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    /// Default placeholder function
    lazy var managedObjectContext: NSManagedObjectContext = {
   
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
               
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}


extension Notification.Name {
    
  
    static let didReceiveFileFromURL = Notification.Name("didReceiveFileFromURL")
    
   
}
