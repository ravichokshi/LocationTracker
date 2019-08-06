//
//  GPXFileManager.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation

let kFileExt = "gpx"


class GPXFileManager: NSObject {
    
   
    class var GPXFilesFolderURL: URL {
        get {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            return documentsUrl
        }
    }
    
  
    class var fileList: [GPXFileInfo] {
        get {
            var GPXFiles: [GPXFileInfo] = []
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
               
                if let directoryURLs = try? fileManager.contentsOfDirectory(at: documentsURL,
                                                                            includingPropertiesForKeys: [.attributeModificationDateKey, .fileSizeKey],
                                                                            options: .skipsSubdirectoryDescendants) {
                 
                    let sortedURLs = directoryURLs.map { url in
                        (url: url,
                         modificationDate: (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast,
                         fileSize: (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
                        }
                        .sorted(by: { $0.1 > $1.1 })
                    print(sortedURLs)
                    
                    for (url, modificationDate, fileSize) in sortedURLs {
                        if url.pathExtension == kFileExt {
                            GPXFiles.append(GPXFileInfo(fileURL: url))
                            
                            print("\(modificationDate) \(modificationDate.timeAgo(numericDates: true)) \(fileSize)bytes -- \(url.deletingPathExtension().lastPathComponent)")
                        }
                    }
                }
            }
            return GPXFiles
        }
    }
    
   
    class func URLForFilename(_ filename: String) -> URL {
        var fullURL = self.GPXFilesFolderURL.appendingPathComponent(filename)
        print("URLForFilename(\(filename): pathForFilename: \(fullURL)")
       
        if fullURL.pathExtension != kFileExt {
            fullURL = fullURL.appendingPathExtension(kFileExt)
        }
        return fullURL
    }
    
    
    class func fileExists(_ filename: String) -> Bool {
        let fileURL = self.URLForFilename(filename)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
   
    class func saveToURL(_ fileURL: URL, gpxContents: String) {
      
        print("Saving file at path: \(fileURL)")
        
        var writeError: NSError?
        let saved: Bool
        do {
            try gpxContents.write(toFile: fileURL.path, atomically: true, encoding: String.Encoding.utf8)
            saved = true
        } catch let error as NSError {
            writeError = error
            saved = false
        }
        if !saved {
            if let error = writeError {
                print("[ERROR] GPXFileManager:save: \(error.localizedDescription)")
            }
        }
        
    }
  
    class func save(_ filename: String, gpxContents: String) {
      
        let fileURL: URL = self.URLForFilename(filename)
        GPXFileManager.saveToURL(fileURL, gpxContents: gpxContents)
    }
    
   
    class func moveFrom(_ fileURL: URL, fileName: String?) {
        
     
        guard let fileName = fileName else {
            print("GPXFileManager:: save failed, error: file name is nil")
            return
        }
        
      
        do {
            let url = GPXFilesFolderURL.path + "/" + fileName
            try FileManager().moveItem(atPath: fileURL.path, toPath: url)
        }
            
           
        catch {
            print("GPXFileManager:: save failed, error: \(error)")
        }
    }
   
    class func removeFileFromURL(_ fileURL: URL) {
        print("Removing file at path: \(fileURL)")
        let defaultManager = FileManager.default
        var error: NSError?
        let deleted: Bool
        do {
            try defaultManager.removeItem(atPath: fileURL.path)
            deleted = true
        } catch let error1 as NSError {
            error = error1
            deleted = false
        }
        if !deleted {
            if let e = error {
                print("[ERROR] GPXFileManager:removeFile: \(fileURL) : \(e.localizedDescription)")
            }
        }
    }
    
    class func removeFile(_ filename: String) {
        let fileURL: URL = self.URLForFilename(filename)
        GPXFileManager.removeFileFromURL(fileURL)
    }
    
   
    class func removeTemporaryFiles() {
        let fileManager = FileManager.default
        do {
            let tmpDirectory = try fileManager.contentsOfDirectory(atPath: NSTemporaryDirectory())
            tmpDirectory.forEach { file in
                let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(file)
                GPXFileManager.removeFileFromURL(fileURL)
            }
        } catch {
            print(error)
        }
    }
}
