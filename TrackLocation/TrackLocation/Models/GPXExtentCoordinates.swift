//
//  GPXExtentCoordinates.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import MapKit


class GPXExtentCoordinates: NSObject {
    
  
    var topLeftCoordinate = CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00)
    
  
    var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00)
    
  
    func extendAreaToIncludeLocation(_ location: CLLocationCoordinate2D) {
        if (topLeftCoordinate.latitude == 0.00) || (location.latitude < topLeftCoordinate.latitude) {
            topLeftCoordinate.latitude = location.latitude
        }
        if (bottomRightCoordinate.latitude == 0.00) || (location.latitude > bottomRightCoordinate.latitude) {
            bottomRightCoordinate.latitude = location.latitude
        }
        
        if (topLeftCoordinate.longitude == 0.00) || (location.longitude > topLeftCoordinate.longitude) {
            topLeftCoordinate.longitude = location.longitude
        }
        if (bottomRightCoordinate.longitude == 0.00) || (location.longitude < bottomRightCoordinate.longitude) {
            bottomRightCoordinate.longitude = location.longitude
        }
    }
    

    var region: MKCoordinateRegion {
        set {
            topLeftCoordinate.latitude = newValue.center.latitude - newValue.span.latitudeDelta/2
            topLeftCoordinate.longitude = newValue.center.longitude + newValue.span.longitudeDelta/2
            bottomRightCoordinate.latitude = newValue.center.latitude + newValue.span.latitudeDelta/2
            bottomRightCoordinate.longitude = newValue.center.longitude - newValue.span.longitudeDelta/2
        }
        
        get {
            let centerLat = (bottomRightCoordinate.latitude + topLeftCoordinate.latitude) / 2
            let centerLon = (bottomRightCoordinate.longitude + topLeftCoordinate.longitude) / 2
            let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
            let latitudeDelta = bottomRightCoordinate.latitude - topLeftCoordinate.latitude
            let longitudeDelta = topLeftCoordinate.longitude - bottomRightCoordinate.longitude
            let span: MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            return MKCoordinateRegion.init(center: center, span: span)
        }
    }
}
