//
//  GPXFileInfo.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation

class GPXFileInfo: NSObject {
    
   
    var fileURL: URL = URL(fileURLWithPath: "")
    
   
    var modifiedDate: Date {
        get {
            return try! fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? Date.distantPast
        }
    }
    
  
    var modifiedDatetimeAgo: String {
        get {
            return modifiedDate.timeAgo(numericDates: true)
        }
    }
    

    var fileSize: Int {
        get {
            return try! fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        }
    }
    
   
    var fileSizeHumanised: String {
        get {
            return fileSize.asFileSize()
        }
    }
    
  
    var fileName: String {
        get {
            return fileURL.deletingPathExtension().lastPathComponent
        }
    }
    
  
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }
    
}
