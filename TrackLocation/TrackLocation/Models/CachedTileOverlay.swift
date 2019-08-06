//
//  CachedTileOverlay.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import MapKit
import Cache


class CachedTileOverlay : MKTileOverlay {
    
   
    var useCache: Bool = true
  
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        //print("CachedTileOverlay:: url() urlTemplate: \(urlTemplate)")
        var urlString = urlTemplate?.replacingOccurrences(of: "{z}", with: String(path.z))
        urlString = urlString?.replacingOccurrences(of: "{x}", with: String(path.x))
        urlString = urlString?.replacingOccurrences(of: "{y}", with: String(path.y))
        
        //get random subdomain
        let subdomains = "abc"
        let rand = arc4random_uniform(UInt32(subdomains.count))
        let randIndex = subdomains.index(subdomains.startIndex, offsetBy: String.IndexDistance(rand));
        urlString = urlString?.replacingOccurrences(of: "{s}", with:String(subdomains[randIndex]))
        print("CachedTileOverlay:: url() urlString: \(urlString ?? "nil")")
        return URL(string: urlString!)!
    }
    
    
    override func loadTile(at path: MKTileOverlayPath,
                           result: @escaping (Data?, Error?) -> Void) {
        let url = self.url(forTilePath: path)
       
        
        if !self.useCache {
            print("CachedTileOverlay:: not using cache")
            return super.loadTile(at: path, result: result)
        }
      
        let diskConfig = DiskConfig(
         
            name: "ImageCache",
          
            expiry: .date(Date().addingTimeInterval(60*24*3600)),
            maxSize: 500 * 1000 * 1000,
            directory: nil
        )
        let memoryConfig = MemoryConfig(
         
            expiry: .date(Date().addingTimeInterval(2*60)),
           
            countLimit: 50,
            
            totalCostLimit: 0
        )
        let cache = try? Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: Data.self)
        )
        let cacheKey = "\(self.urlTemplate ?? "none")-\(path.x)-\(path.y)-\(path.z)"
       
        cache?.async.object(forKey: cacheKey) { object in
            switch object {
            case .value(let cached):
           
                result(cached,nil)
            case .error:
            
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        result(nil,error)
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            DispatchQueue.main.async {
                                result(nil, error)
                            }
                            return
                    }
                   
                    cache?.async.setObject(data!, forKey: cacheKey) { error in
                        print("ERROR saving in cache: \(error)")
                    }
                    DispatchQueue.main.async {
                        result(data, nil)
                    }
                }
                task.resume()
            }
        }
        
       
    }
}
