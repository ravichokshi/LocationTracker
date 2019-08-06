//
//  CoreDataHelper.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import CoreData
import CoreGPX


class CoreDataHelper {
    
   
    var waypointId = Int64()
   
    var trackpointId = Int64()
    

    var tracksegmentId = Int64()
    
  
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
  
    var tracksegments = [GPXTrackSegment]()
    
  
    var currentSegment = GPXTrackSegment()
    
   
    var waypoints = [GPXWaypoint]()
    

    var lastFileName = String()
    
  
    func add(toCoreData lastFileName: String) {
        
        let childManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      
        childManagedObjectContext.parent = appDelegate.managedObjectContext
        
        childManagedObjectContext.perform {
            let root = NSEntityDescription.insertNewObject(forEntityName: "CDRoot", into: childManagedObjectContext) as! CDRoot
            
            root.lastFileName = lastFileName
            
            do {
                try childManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                      
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save parent context when adding last file name: \(error)")
                    }
                }
            }
            catch {
                print("Failure to save child context when adding last file name: \(error)")
            }
        }
    }
  
    func add(toCoreData trackpoint: GPXTrackPoint, withTrackSegmentID Id: Int) {
        let childManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      
        childManagedObjectContext.parent = appDelegate.managedObjectContext
        
        childManagedObjectContext.perform {
            print("Core Data Helper: Add trackpoint with id: \(self.trackpointId)")
            let pt = NSEntityDescription.insertNewObject(forEntityName: "CDTrackpoint", into: childManagedObjectContext) as! CDTrackpoint
            
            guard let elevation = trackpoint.elevation else { return }
            guard let latitude = trackpoint.latitude   else { return }
            guard let longitude = trackpoint.longitude else { return }
            
            pt.elevation = elevation
            pt.latitude = latitude
            pt.longitude = longitude
            pt.time = trackpoint.time
            pt.trackpointId = self.trackpointId
            pt.trackSegmentId = Int64(Id)
            
          
            do {
                let serialized = try JSONEncoder().encode(trackpoint)
                pt.serialized = serialized
            }
            catch {
                print("Core Data Helper: serialization error when adding trackpoint: \(error)")
            }
            
            self.trackpointId += 1
            
            do {
                try childManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                       
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save parent context when adding trackpoint: \(error)")
                    }
                }
            }
            catch {
                print("Failure to save child context when adding trackpoint: \(error)")
            }
        }
    }
    
   
    func add(toCoreData waypoint: GPXWaypoint) {
        let waypointChildManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      
        waypointChildManagedObjectContext.parent = appDelegate.managedObjectContext
        
        waypointChildManagedObjectContext.perform {
            print("Core Data Helper: Add waypoint with id: \(self.waypointId)")
            let pt = NSEntityDescription.insertNewObject(forEntityName: "CDWaypoint", into: waypointChildManagedObjectContext) as! CDWaypoint
            
            guard let latitude = waypoint.latitude   else { return }
            guard let longitude = waypoint.longitude else { return }
            
            if let elevation = waypoint.elevation {
                pt.elevation = elevation
            }
            else {
                pt.elevation = .greatestFiniteMagnitude
            }
            
            pt.name = waypoint.name
            pt.desc = waypoint.desc
            pt.latitude = latitude
            pt.longitude = longitude
            pt.time = waypoint.time
            pt.waypointId = self.waypointId
            
            
            do {
                let serialized = try JSONEncoder().encode(waypoint)
                pt.serialized = serialized
            }
            catch {
                print("Core Data Helper: serialization error when adding waypoint: \(error)")
            }
            
            self.waypointId += 1
            
            do {
                try waypointChildManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                      
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save parent context when adding waypoint: \(error)")
                    }
                }
            }
            catch {
                print("Failure to save parent context when adding waypoint: \(error)")
            }
        }
    }
    
   
    func update(toCoreData updatedWaypoint: GPXWaypoint, from index: Int) {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
       
        let wptFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: updating waypoint in Core Data")
            
           
            guard let waypointResults = asynchronousFetchResult.finalResult as? [CDWaypoint] else { return }
            
            privateManagedObjectContext.perform {
                let objectID = waypointResults[index].objectID
                guard let pt = self.appDelegate.managedObjectContext.object(with: objectID) as? CDWaypoint else { return }
                
                guard let latitude = updatedWaypoint.latitude   else { return }
                guard let longitude = updatedWaypoint.longitude else { return }
                
                if let elevation = updatedWaypoint.elevation {
                    pt.elevation = elevation
                }
                else {
                    pt.elevation = .greatestFiniteMagnitude
                }
                
                pt.name = updatedWaypoint.name
                pt.desc = updatedWaypoint.desc
                pt.latitude = latitude
                pt.longitude = longitude
                
                do {
                    try privateManagedObjectContext.save()
                    self.appDelegate.managedObjectContext.performAndWait {
                        do {
                           
                            try self.appDelegate.managedObjectContext.save()
                        } catch {
                            print("Failure to update and save waypoint to parent context: \(error)")
                        }
                    }
                }
                catch {
                    print("Failure to update and save waypoint to context at child context: \(error)")
                }
            }
            
        }
        
        do {
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch {
            print("NSAsynchronousFetchRequest (for finding updatable waypoint) error: \(error)")
        }
    }
    
   
    func retrieveFromCoreData() {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
    
        let trkptFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDTrackpoint")
        let wptFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        let rootFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDRoot")
        
      
        let sortTrkpt = NSSortDescriptor(key: "trackpointId", ascending: true)
        let sortWpt = NSSortDescriptor(key: "waypointId", ascending: true)
        trkptFetchRequest.sortDescriptors = [sortTrkpt]
        wptFetchRequest.sortDescriptors = [sortWpt]
        
        let asyncRootFetchRequest = NSAsynchronousFetchRequest(fetchRequest: rootFetchRequest) { asynchronousFetchResult in
            guard let rootResults = asynchronousFetchResult.finalResult as? [CDRoot] else {
                return }
            
            DispatchQueue.main.async {
                guard let objectID = rootResults.last?.objectID else { self.lastFileName = ""; return }
                guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDRoot else { self.lastFileName = ""; return }
                self.lastFileName = safePoint.lastFileName ?? ""
            }
        }
        
       
        let asynchronousTrackPointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: trkptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: fetching recoverable trackpoints from Core Data")
            
            guard let trackPointResults = asynchronousFetchResult.finalResult as? [CDTrackpoint] else { return }
           
            DispatchQueue.main.async {
                self.tracksegmentId = trackPointResults.first?.trackSegmentId ?? 0
                
                for result in trackPointResults {
                    let objectID = result.objectID
                    
                    // thread safe
                    guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDTrackpoint else { continue }
                    
                    if self.tracksegmentId != safePoint.trackSegmentId {
                        if self.currentSegment.trackpoints.count > 0 {
                            self.tracksegments.append(self.currentSegment)
                            self.currentSegment = GPXTrackSegment()
                        }
                        
                        self.tracksegmentId = safePoint.trackSegmentId
                    }
                    
                    let pt = GPXTrackPoint(latitude: safePoint.latitude, longitude: safePoint.longitude)
                    
                    pt.time = safePoint.time
                    pt.elevation = safePoint.elevation
                    
                    self.currentSegment.trackpoints.append(pt)
                    
                }
                self.trackpointId = trackPointResults.last?.trackpointId ?? Int64()
                self.tracksegments.append(self.currentSegment)
            }
        }
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: fetching recoverable waypoints from Core Data")
            
          
            guard let waypointResults = asynchronousFetchResult.finalResult as? [CDWaypoint] else { return }
            
         
            DispatchQueue.main.async {
                for result in waypointResults {
                    let objectID = result.objectID
                    
                   
                    guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDWaypoint else { continue }
                    
                    let pt = GPXWaypoint(latitude: safePoint.latitude, longitude: safePoint.longitude)
                    
                    pt.time = safePoint.time
                    pt.desc = safePoint.desc
                    pt.name = safePoint.name
                    if safePoint.elevation != .greatestFiniteMagnitude {
                        pt.elevation = safePoint.elevation
                    }
                    
                    self.waypoints.append(pt)
                }
                
                self.waypointId = waypointResults.last?.waypointId ?? Int64()
                
               
                self.crashFileRecovery()
                print("Core Data Helper: async fetches complete.")
            }
        }
        
        do {
            
            try privateManagedObjectContext.execute(asyncRootFetchRequest)
            try privateManagedObjectContext.execute(asynchronousTrackPointFetchRequest)
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest (fetch request for recovery) error: \(error)")
        }
    }
    
  
    func deleteLastFileNameFromCoreData() {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
       
        let rootFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDRoot")
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: rootFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: delete last filename from Core Data.")
            
            
            guard let results = asynchronousFetchResult.finalResult as? [CDRoot] else { return }
            
            for result in results {
                privateManagedObjectContext.delete(result)
            }
            
            do {
                try privateManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                      
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save context: \(error)")
                    }
                }
            }
            catch {
                print("Failure to save context at child context: \(error)")
            }
        }
        
        do {
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest (while deleting last file name) error: \(error)")
        }
    }
    
   
    func deleteWaypoint(fromCoreDataAt index: Int) {
        lastFileName = String()
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
      
        let wptFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: delete waypoint from Core Data at index: \(index)")
            
           
            guard let waypointResults = asynchronousFetchResult.finalResult as? [CDWaypoint] else { return }
            
            privateManagedObjectContext.delete(waypointResults[index])
            
            do {
                try privateManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save context (when deleting waypoint): \(error)")
                    }
                }
            }
            catch {
                print("Failure to save context at child context (when deleting waypoint): \(error)")
            }
        }
        
        do {
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest (for finding deletable waypoint) error: \(error)")
        }
        
    }
    
    

    func deleteAllPointsFromCoreData() {
        
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        
        print("Core Data Helper: Batch Delete trackpoints and waypoints from Core Data")
        
      
        let trackpointFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDTrackpoint")
        let waypointFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        
        if #available(iOS 9.0, *) {
            privateManagedObjectContext.perform {
                do {
                    let trackpointDeleteRequest = NSBatchDeleteRequest(fetchRequest: trackpointFetchRequest)
                    let waypointDeleteRequest = NSBatchDeleteRequest(fetchRequest: waypointFetchRequest)
                    
                    
                    try privateManagedObjectContext.execute(trackpointDeleteRequest)
                    try privateManagedObjectContext.execute(waypointDeleteRequest)
                    
                    try privateManagedObjectContext.save()
                    
                    self.appDelegate.managedObjectContext.performAndWait {
                        do {
                            
                            try self.appDelegate.managedObjectContext.save()
                        } catch {
                            print("Failure to save context after delete: \(error)")
                        }
                    }
                }
                catch {
                    print("Failed to delete all from core data, error: \(error)")
                }
                
            }
            
        }
        else {
            let trackpointAsynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: trackpointFetchRequest) { asynchronousFetchResult in
                
                guard let results = asynchronousFetchResult.finalResult as? [CDTrackpoint] else { return }
                
                for result in results {
                    privateManagedObjectContext.delete(result)
                }
            }
            
            let waypointAsynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: waypointFetchRequest) { asynchronousFetchResult in
                
                guard let results = asynchronousFetchResult.finalResult as? [CDWaypoint] else { return }
                
             
                
                for result in results {
                    privateManagedObjectContext.delete(result)
                }
            }
            
            do {
              
                try privateManagedObjectContext.execute(trackpointAsynchronousFetchRequest)
                try privateManagedObjectContext.execute(waypointAsynchronousFetchRequest)
                try privateManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save context after delete: \(error)")
                    }
                }
                
            } catch let error {
                print("NSAsynchronousFetchRequest (for batch delete <iOS 9) error: \(error)")
            }
        }
    }
    
    
    func crashFileRecovery() {
        DispatchQueue.global().async {
           
            if self.currentSegment.trackpoints.count > 0 || self.waypoints.count > 0 {
                
                let root: GPXRoot
                let track = GPXTrack()
                
              
                if self.lastFileName != "" {
                    let gpx = GPXFileManager.URLForFilename(self.lastFileName)
                    let parsedRoot = GPXParser(withURL: gpx)?.parsedData()
                    root = parsedRoot ?? GPXRoot(creator: kGPXCreatorString)
                }
                else {
                    root = GPXRoot(creator: kGPXCreatorString)
                }
                
                
                track.tracksegments = self.tracksegments
                root.add(track: track)
                root.waypoints = [GPXWaypoint]()
                root.add(waypoints: self.waypoints)
                
                DispatchQueue.main.sync {
                  
                    let alertController = UIAlertController(title: "Continue last session?", message: "What would you like to do with the recovered content from last session?", preferredStyle: .actionSheet)
                    
                   
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                        self.clearAll()
                    }
                   
                    let continueAction = UIAlertAction(title: "Continue Session", style: .default) { (action) in
                        NotificationCenter.default.post(name: .loadRecoveredFile, object: nil, userInfo: ["recoveredRoot" : root, "fileName" : self.lastFileName])
                    }
                    
                   
                    let saveAction = UIAlertAction(title: "Save and Start New", style: .default) { (action) in
                        self.saveFile(from: root, andIfAvailable: self.lastFileName)
                    }
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(continueAction)
                    alertController.addAction(saveAction)
                    CoreDataAlertView().showActionSheet(alertController)
                }
            }
            else {
               
            }
        }
        
    }
    
    
    func saveFile(from gpx: GPXRoot, andIfAvailable lastfileName: String) {
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy-HHmm"
        var fileName = String()
        
        if lastfileName != "" {
            fileName = lastfileName
        }
        else if let lastTrkptDate = gpx.tracks.last?.tracksegments.last?.trackpoints.last?.time {
            fileName = dateFormatter.string(from: lastTrkptDate)
        }
        else {
           
            fileName = dateFormatter.string(from: Date())
        }
        
        let recoveredFileName = "recovery-\(fileName)"
        let gpxString = gpx.gpx()
        
        
        GPXFileManager.save(recoveredFileName, gpxContents: gpxString)
        print("File \(recoveredFileName) was recovered from previous session, prior to unexpected crash/exit")
        
        
        self.clearAll()
        self.deleteLastFileNameFromCoreData()
    }
    
   
    func resetIds() {
        self.trackpointId = Int64()
        self.waypointId = Int64()
        self.tracksegmentId = Int64()
    }
    
   
    func clearObjects() {
        self.tracksegments = []
        self.waypoints = []
        self.currentSegment = GPXTrackSegment()
    }
    

    func clearAll() {
     
        self.deleteAllPointsFromCoreData()
        
     
        self.clearObjects()
        
        
        self.currentSegment = GPXTrackSegment()
        
        self.resetIds()
        
    }
    
}
