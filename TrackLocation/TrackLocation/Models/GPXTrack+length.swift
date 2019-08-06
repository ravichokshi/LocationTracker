//
//  GPXTrack+length.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import MapKit
import CoreGPX


extension GPXTrack {
    
   
    public var length: CLLocationDistance {
        get {
            var trackLength: CLLocationDistance = 0.0
            for segment in tracksegments {
                trackLength += segment.length()
            }
            return trackLength
        }
    }
}
