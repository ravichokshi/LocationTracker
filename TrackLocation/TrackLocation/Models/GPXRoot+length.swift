//
//  GPXRoot+length.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import MapKit
import CoreGPX


extension GPXRoot {
    
 
    public var tracksLength: CLLocationDistance {
        get {
            var tLength: CLLocationDistance = 0.0
            for track in self.tracks {
                tLength += track.length
            }
            return tLength
        }
    }
}
