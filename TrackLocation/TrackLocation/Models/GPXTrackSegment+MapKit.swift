//
//  GPXTrackSegment+MapKit.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreGPX

#if os(iOS)
extension GPXTrackSegment {
    
    public var overlay: MKPolyline {
        get {
            var coords: [CLLocationCoordinate2D] = self.trackPointsToCoordinates()
            let pl = MKPolyline(coordinates: &coords, count:  coords.count)
            return pl
        }
    }
}
#endif

extension GPXTrackSegment {
  
    func trackPointsToCoordinates() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        for point in self.trackpoints {
            coords.append(point.coordinate)
        }
        return coords
    }
    
   
    func length() -> CLLocationDistance {
        var length: CLLocationDistance = 0.0
        var distanceTwoPoints: CLLocationDistance
       
        if self.trackpoints.count < 2 {
            return length
        }
        var prev: CLLocation?
        for point in self.trackpoints {
            let pt: CLLocation = CLLocation(latitude: Double(point.latitude!), longitude: Double(point.longitude!) )
            if prev == nil {
                prev = pt
                continue
            }
            distanceTwoPoints = pt.distance(from: prev!)
            length += distanceTwoPoints
          
            prev = pt
        }
        return length
    }
}
