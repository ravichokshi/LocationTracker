//
//  GPXFilesTableViewControllerDelegate.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import CoreGPX


protocol GPXFilesTableVCDelegate: class {
    
   
    func loadGPXFileWithName(_ gpxFilename: String, gpxRoot: GPXRoot)
    
}
