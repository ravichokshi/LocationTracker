//
//  PreferencesTableViewControllerDelegate.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation


protocol PreferencesTableViewControllerDelegate: class {
    
   
    func didUpdateTileServer(_ newGpxTileServer: Int)
    
   
    func didUpdateUseCache(_ newUseCache: Bool)
    
   
    func didUpdateUseImperial(_ newUseImperial: Bool)
    
    
}
