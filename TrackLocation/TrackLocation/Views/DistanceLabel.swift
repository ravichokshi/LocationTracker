//
//  DistanceLabel.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
open class DistanceLabel: UILabel {
    
 
    private var _distance = 0.0

    private var _useImperial = false

    open var useImperial: Bool {
        get {
            return _useImperial
        }
        set {
            _useImperial = newValue
            distance = _distance
        }
    }
    
  
    open var distance: CLLocationDistance {
        get {
            return _distance
        }
        set {
            _distance = newValue
            text = newValue.toDistance(useImperial: useImperial)
        }
    }
}
