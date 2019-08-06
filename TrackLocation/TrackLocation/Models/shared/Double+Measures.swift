//
//  Double+Measures.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation

let kMetersPerMile = 1609.344

let kMetersPerKilometer = 1000.0


let kMetersPerFeet = 0.3048


let kKilometersPerHourInOneMeterPerSecond = 3.6

let kMilesPerHourInOneMeterPerSecond = 2.237


extension Double {
    
  
    func toFeet() -> Double {
        return self/kMetersPerFeet
    }
    
  
    func toFeet() -> String {
        return String(format: "%.0fft", self.toFeet() as Double)
    }
    
  
    func toMiles() -> Double {
        return self/kMetersPerMile
    }
    
  
    func toMiles() -> String {
        return String(format: "%.2fmi", toMiles() as Double)
    }
    
  
    func toKilometers() -> Double {
        return self/kMetersPerKilometer
    }
    
   
    func toKilometers() -> String {
        return String(format: "%.2fkm", toKilometers() as Double)
    }
   
    func toMeters() -> String {
        return String(format: "%.0fm", self)
    }
    
   
    func toDistance(useImperial: Bool = false) -> String {
        if useImperial {
            return toMiles() as String
        } else {
            return self > kMetersPerKilometer ? toKilometers() as String : toMeters() as String
        }
    }
    
  
    func toMilesPerHour() -> Double {
        return self * kMilesPerHourInOneMeterPerSecond
    }
    
   
    func toMilesPerHour() -> String {
        return String(format: "%.2fmph", toMilesPerHour() as Double)
    }
    
    
    func toKilometersPerHour() -> Double {
        return self * kKilometersPerHourInOneMeterPerSecond
    }
    
  
    func toKilometersPerHour() -> String {
        return String(format: "%.2fkm/h", toKilometersPerHour() as Double)
    }
    

    func toSpeed(useImperial: Bool = false) -> String {
        return useImperial ? toMilesPerHour() : toKilometersPerHour() as String
    }
    
  
    func toAltitude(useImperial: Bool = false) -> String {
        return useImperial ? toFeet() : toMeters() as String
    }
    
   
    func toAccuracy(useImperial: Bool = false) -> String {
        return "±\(useImperial ? toFeet() as String : toMeters() as String)"
    }
    
}
