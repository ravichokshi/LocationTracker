//
//  GPXMapView.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreGPX
import CoreData



class GPXMapView: MKMapView {
    
  
    let session = GPXSession()
    
    var currentSegmentOverlay: MKPolyline
    

    var extent: GPXExtentCoordinates = GPXExtentCoordinates() //extent of the GPX points and tracks
  
    var compassRect : CGRect
    

    var useCache: Bool = true {
        didSet {
            if self.tileServerOverlay is CachedTileOverlay {
                print("GPXMapView:: setting useCache \(self.useCache)")
                (self.tileServerOverlay as! CachedTileOverlay).useCache = self.useCache
            }
        }
    }
    

    var headingImageView: UIImageView?
    
  
    var tileServer: GPXTileServer = .apple {
        willSet {
           
            print("Setting map tiles overlay to: \(newValue.name)" )
            
         
            if self.tileServer != .apple {
                
                self.removeOverlay(self.tileServerOverlay)
            }
            
            if newValue != .apple {
                self.tileServerOverlay = CachedTileOverlay(urlTemplate: newValue.templateUrl)
                (self.tileServerOverlay as! CachedTileOverlay).useCache = self.useCache
                tileServerOverlay.canReplaceMapContent = true
                self.insertOverlay(tileServerOverlay, at: 0, level: .aboveLabels)
            }
        }
    }
    

    var tileServerOverlay: MKTileOverlay = MKTileOverlay()
    

    let coreDataHelper = CoreDataHelper()
    
  
    required init?(coder aDecoder: NSCoder) {
        var tmpCoords: [CLLocationCoordinate2D] = [] //init with empty
        self.currentSegmentOverlay = MKPolyline(coordinates: &tmpCoords, count: 0)
        self.compassRect = CGRect.init(x: 0, y: 0, width: 36, height: 36)
        super.init(coder: aDecoder)
    }
    
   
    override func layoutSubviews() {
        super.layoutSubviews()
        if let compassView = self.subviews.filter({ $0.isKind(of:NSClassFromString("MKCompassView")!) }).first {
            if compassRect.origin.x != 0 {
                compassView.frame = compassRect
            }
        }
    }
    
 
    func addWaypointAtViewPoint(_ point: CGPoint) {
        let coords: CLLocationCoordinate2D = self.convert(point, toCoordinateFrom: self)
        let waypoint = GPXWaypoint(coordinate: coords)
        self.addWaypoint(waypoint)
        self.coreDataHelper.add(toCoreData: waypoint)
        
    }
 
    func addWaypoint(_ waypoint: GPXWaypoint) {
        self.session.addWaypoint(waypoint)
        self.addAnnotation(waypoint)
        self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
    }
    
   
    func removeWaypoint(_ waypoint: GPXWaypoint) {
        let index = session.waypoints.firstIndex(of: waypoint)
        if index == nil {
            print("Waypoint not found")
            return
        }
        self.removeAnnotation(waypoint)
        self.session.waypoints.remove(at: index!)
        self.coreDataHelper.deleteWaypoint(fromCoreDataAt: index!)
       
        
    }
    
   
    func updateHeading(_ heading: CLHeading) {
        headingImageView?.isHidden = false
        let rotation = CGFloat(heading.trueHeading/180 * Double.pi)
        headingImageView?.transform = CGAffineTransform(rotationAngle: rotation)
    }
    
    
    func addPointToCurrentTrackSegmentAtLocation(_ location: CLLocation) {
        let pt = GPXTrackPoint(location: location)
        self.coreDataHelper.add(toCoreData: pt, withTrackSegmentID: session.trackSegments.count)
        self.session.addPointToCurrentTrackSegmentAtLocation(location)
    
        self.removeOverlay(currentSegmentOverlay)
        currentSegmentOverlay = self.session.currentSegment.overlay
        self.addOverlay(currentSegmentOverlay)
        self.extent.extendAreaToIncludeLocation(location.coordinate)
    }
    
  
    func startNewTrackSegment() {
        if self.session.currentSegment.trackpoints.count > 0 {
            self.session.startNewTrackSegment()
            self.currentSegmentOverlay = MKPolyline()
        }
    }
    
   
    func finishCurrentSegment() {
        self.startNewTrackSegment()
    }
    

    func clearMap() {
        self.session.reset()
        self.removeOverlays(self.overlays)
        self.removeAnnotations(self.annotations)
        self.extent = GPXExtentCoordinates()
     
        if tileServer != .apple {
            self.addOverlay(tileServerOverlay, level: .aboveLabels)
        }
    }
    
  
    func exportToGPXString() -> String {
        return self.session.exportToGPXString()
    }
    
   
    func regionToGPXExtent() {
        self.setRegion(extent.region, animated: true)
    }
    
    
    func importFromGPXRoot(_ gpx: GPXRoot) {
       
        self.clearMap()
        for pt in gpx.waypoints {
            self.addWaypoint(pt)
            self.coreDataHelper.add(toCoreData: pt)
        }
     
        self.session.tracks = gpx.tracks
        for oneTrack in self.session.tracks {
            self.session.totalTrackedDistance += oneTrack.length
            for segment in oneTrack.tracksegments {
                let overlay = segment.overlay
                self.addOverlay(overlay)
                let segmentTrackpoints = segment.trackpoints
               
                for waypoint in segmentTrackpoints {
                    self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
    }
    
    func continueFromGPXRoot(_ gpx: GPXRoot) {
     
        self.clearMap()
        
        for pt in gpx.waypoints {
            self.addWaypoint(pt)
        }
        
        self.session.continueFromGPXRoot(gpx)
        
       
        for oneTrack in self.session.tracks {
            session.totalTrackedDistance += oneTrack.length
            for segment in oneTrack.tracksegments {
                let overlay = segment.overlay
                self.addOverlay(overlay)
                
                let segmentTrackpoints = segment.trackpoints
             
                for waypoint in segmentTrackpoints {
                    self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
  
        for trackSegment in self.session.trackSegments {
            
            let overlay = trackSegment.overlay
            self.addOverlay(overlay)
            
            let segmentTrackpoints = trackSegment.trackpoints
         
            for waypoint in segmentTrackpoints {
                self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
            }
        }
        
    }
}


