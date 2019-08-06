//
//  Preferences.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation

let kDefaultsKeyTileServerInt: String = "TileServerInt"


let kDefaultsKeyUseCache: String = "UseCache"


let kDefaultsKeyUseImperial: String = "UseImperial"


class Preferences: NSObject {
    
  
    static let shared = Preferences()
    
 
    private var _useImperial: Bool = false
    
  
    private var _useCache: Bool = true
    

    private var _tileServer: GPXTileServer = .apple
    
   
    private let defaults = UserDefaults.standard
    
   
    private override init() {
      
        if let useImperialDefaults = defaults.object(forKey: kDefaultsKeyUseImperial) as? Bool {
            print("Preferences:: loaded from defaults. useImperial: \(useImperialDefaults)")
            _useImperial = useImperialDefaults
        } else {
            let locale = NSLocale.current
            _useImperial = !locale.usesMetricSystem
            print("Preferences:: NO defaults for useImperial. Using locale: \(locale.languageCode ?? "unknown") useImperial: \(_useImperial) usesMetric:\(locale.usesMetricSystem)")
        }
        
       
        if let useCacheFromDefaults = defaults.object(forKey: kDefaultsKeyUseCache) as? Bool {
            _useCache = useCacheFromDefaults
            print("Preferences:: loaded preference from defaults useCache= \(useCacheFromDefaults)");
        }
        
       
        if var tileServerInt = defaults.object(forKey: kDefaultsKeyTileServerInt) as? Int {
            
            tileServerInt = tileServerInt >= GPXTileServer.count ? GPXTileServer.apple.rawValue : tileServerInt
            _tileServer = GPXTileServer(rawValue: tileServerInt)!
            print("Preferences:: loaded preference from defaults tileServerInt \(tileServerInt)")
        }
    }
    

    var useImperial: Bool {
        get {
            return _useImperial
        }
        set {
            _useImperial = newValue
            defaults.set(newValue, forKey: kDefaultsKeyUseImperial)
        }
    }
    
  
    var useCache: Bool {
        get {
            return _useCache
        }
        set {
            _useCache = newValue
        
            defaults.set(newValue, forKey: kDefaultsKeyUseCache)
        }
    }
    
  
    var tileServer: GPXTileServer {
        get {
            return _tileServer
        }
        
        set {
            _tileServer = newValue
            defaults.set(newValue.rawValue, forKey: kDefaultsKeyTileServerInt)
        }
    }
    
 
    var tileServerInt: Int {
        get {
            return _tileServer.rawValue
        }
        set {
            _tileServer = GPXTileServer(rawValue: newValue)!
            defaults.set(newValue, forKey: kDefaultsKeyTileServerInt)
        }
    }
}
