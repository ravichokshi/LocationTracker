//
//  GPXSession.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import CoreGPX
import CoreLocation



let kGPXCreatorString = "Open GPX Tracker for iOS"




class GPXSession {
    
 
    var waypoints: [GPXWaypoint] = []
    
  
    var tracks: [GPXTrack] = []
    
    
    var trackSegments: [GPXTrackSegment] = []
    
   
    var currentSegment: GPXTrackSegment =  GPXTrackSegment()
    
    
    var totalTrackedDistance = 0.00
    
  
    var currentTrackDistance = 0.00
    
  
    var currentSegmentDistance = 0.00
    
    
 
    func addWaypoint(_ waypoint: GPXWaypoint) {
        self.waypoints.append(waypoint)
    }
    
    
    func removeWaypoint(_ waypoint: GPXWaypoint) {
        let index = waypoints.firstIndex(of: waypoint)
        if index == nil {
            print("Waypoint not found")
            return
        }
        waypoints.remove(at: index!)
    }
    
   
    func addPointToCurrentTrackSegmentAtLocation(_ location: CLLocation) {
        let pt = GPXTrackPoint(location: location)
        self.currentSegment.add(trackpoint: pt)
        
        
        if self.currentSegment.trackpoints.count >= 2 {
            let prevPt = self.currentSegment.trackpoints[self.currentSegment.trackpoints.count-2]
            guard let latitude = prevPt.latitude, let longitude = prevPt.longitude else { return }
            let prevPtLoc = CLLocation(latitude: latitude, longitude: longitude)
           
            let distance = prevPtLoc.distance(from: location)
            self.currentTrackDistance += distance
            self.totalTrackedDistance += distance
            self.currentSegmentDistance += distance
        }
    }
    
   
    func startNewTrackSegment() {
        if self.currentSegment.trackpoints.count > 0 {
            self.trackSegments.append(self.currentSegment)
            self.currentSegment = GPXTrackSegment()
            self.currentSegmentDistance = 0.00
        }
    }
    
  
    func reset() {
        self.trackSegments = []
        self.tracks = []
        self.currentSegment = GPXTrackSegment()
        self.waypoints = []
        
        self.totalTrackedDistance = 0.00
        self.currentTrackDistance = 0.00
        self.currentSegmentDistance = 0.00
        
    }
    
   
    func exportToGPXString() -> String {
        print("Exporting session data into GPX String")
       
        let gpx = GPXRoot(creator: kGPXCreatorString)
        gpx.add(waypoints: self.waypoints)
        let track = GPXTrack()
        track.add(trackSegments: self.trackSegments)
       
        if self.currentSegment.trackpoints.count > 0 {
            track.add(trackSegment: self.currentSegment)
        }
      
        gpx.add(tracks: self.tracks)
      
        gpx.add(track: track)
        return gpx.gpx()
    }
    
    func continueFromGPXRoot(_ gpx: GPXRoot) {
        
        let lastTrack = gpx.tracks.last ?? GPXTrack()
        totalTrackedDistance += lastTrack.length
        
        self.tracks = gpx.tracks
        
      
        self.tracks.removeLast()
        
        self.trackSegments = lastTrack.tracksegments
        
    }
    
}
