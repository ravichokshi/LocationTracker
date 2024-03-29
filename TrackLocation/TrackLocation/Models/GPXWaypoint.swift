//
//  GPXWaypoint.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import MapKit
import CoreGPX


extension GPXWaypoint : MKAnnotation {
    
   
    convenience init (coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let timeFormat = DateFormatter()
        timeFormat.dateStyle = DateFormatter.Style.none
        timeFormat.timeStyle = DateFormatter.Style.medium
      
        
        let subtitleFormat = DateFormatter()
       
        subtitleFormat.dateStyle = DateFormatter.Style.medium
        subtitleFormat.timeStyle = DateFormatter.Style.medium
        
        let now = Date()
        self.time = now
        self.title = timeFormat.string(from: now)
        self.subtitle = subtitleFormat.string(from: now)
    }
    
    convenience init (coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance?) {
        self.init(coordinate: coordinate)
        self.elevation = altitude
    }
    
    public var title: String? {
        set {
            self.name = newValue
        }
        get {
            return self.name
        }
    }
    
 
    public var subtitle: String? {
        set {
            self.desc = newValue
        }
        get {
            return self.desc
        }
    }
    
 
    public var coordinate: CLLocationCoordinate2D {
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: self.latitude!, longitude: CLLocationDegrees(self.longitude!))
        }
    }
}
