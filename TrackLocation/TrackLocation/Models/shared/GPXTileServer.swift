//
//  GPXTileServer.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation

enum GPXTileServer: Int {
    
  
    case apple
    
   
    case openStreetMap
   
    case cartoDB
    
   
    var name: String {
        switch self {
        case .apple: return "Apple Mapkit (no offline cache)"
        case .openStreetMap: return "Open Street Map"
        case .cartoDB: return "Carto DB"
          
        }
    }
    
   
    var templateUrl: String {
        switch self {
        case .apple: return ""
        case .openStreetMap: return "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        case .cartoDB: return "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"
            
            
        }
    }
  
    static var count: Int { return GPXTileServer.cartoDB.rawValue + 1}
}
