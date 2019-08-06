//
//  PreferencesTableViewController.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import UIKit

import Cache


let kUnitsSection = 0


let kCacheSection = 1


let kMapSourceSection = 2


let kUseImperialUnitsCell = 0


let kUseOfflineCacheCell = 0


let kClearCacheCell = 1


class PreferencesTableViewController: UITableViewController, UINavigationBarDelegate {
    
   
    weak var delegate: PreferencesTableViewControllerDelegate?
    

    var preferences : Preferences = Preferences.shared
 
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
       
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        self.title = "Preferences"
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PreferencesTableViewController.closePreferencesTableViewController))
        self.navigationItem.rightBarButtonItems = [shareItem]
    }
    
 
    @objc func closePreferencesTableViewController() {
        print("closePreferencesTableViewController()")
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
  
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
  
    override func numberOfSections(in tableView: UITableView?) -> Int {
        
        return 3
    }
    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case kUnitsSection: return "Units"
        case kCacheSection: return "Cache"
        case kMapSourceSection: return "Map source"
        default: fatalError("Unknown section")
        }
    }
    
  
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case kCacheSection: return 2
        case kUnitsSection: return 1
        case kMapSourceSection: return GPXTileServer.count
        default: fatalError("Unknown section")
        }
    }
    
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .value1, reuseIdentifier: "MapCell")
        
        
        if indexPath.section == kUnitsSection {
            switch (indexPath.row) {
            case kUseImperialUnitsCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = "Use imperial units?"
                if preferences.useImperial {
                    cell.accessoryType = .checkmark
                }
            default: fatalError("Unknown section")
            }
        }
        
       
        if indexPath.section == kCacheSection {
            switch (indexPath.row) {
            case kUseOfflineCacheCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = "Offline cache"
                if preferences.useCache {
                    cell.accessoryType = .checkmark
                }
            case kClearCacheCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = "Clear cache"
                cell.textLabel?.textColor = UIColor.red
            default: fatalError("Unknown section")
            }
        }
        
     
        if indexPath.section == kMapSourceSection {
           
            let tileServer = GPXTileServer(rawValue: indexPath.row)
            cell.textLabel?.text = tileServer!.name
            if indexPath.row == preferences.tileServerInt {
                cell.accessoryType = .checkmark
            }
            
            return cell
        }
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == kUnitsSection {
            switch indexPath.row {
            case kUseImperialUnitsCell:
                let newUseImperial = !preferences.useImperial
                preferences.useImperial = newUseImperial
                print("PreferencesTableViewController: toggle imperial units to \(newUseImperial)")
               
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseImperial ? .checkmark : .none
           
                self.delegate?.didUpdateUseImperial(newUseImperial)
            default:
                fatalError("didSelectRowAt: Unknown cell")
            }
        }
        if indexPath.section == kCacheSection {
            switch indexPath.row {
            case kUseOfflineCacheCell:
                print("toggle cache")
                let newUseCache = !preferences.useCache
                preferences.useCache = newUseCache
               
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseCache ? .checkmark : .none
               
                self.delegate?.didUpdateUseCache(newUseCache)
            case kClearCacheCell:
                print("clear cache")
                
                do {
                    let diskConfig = DiskConfig(name: "ImageCache")
                    let cache = try Storage(
                        diskConfig: diskConfig,
                        memoryConfig: MemoryConfig(),
                        transformer: TransformerFactory.forData()
                    )
                  
                    cache.async.removeAll(completion: { (result) in
                        if case .value = result {
                            print("Cache cleaned")
                            let cell = tableView.cellForRow(at: indexPath)!
                            cell.textLabel?.text = "Cache is now empty"
                            cell.textLabel?.textColor = UIColor.gray
                        }
                    })
                } catch {
                    print(error)
                }
            default:
                fatalError("didSelectRowAt: Unknown cell")
            }
        }
        if indexPath.section == kMapSourceSection {
            print("PreferenccesTableView Map Tile Server section Row at index:  \(indexPath.row)")
            
           
            let selectedTileServerIndexPath = IndexPath(row: preferences.tileServerInt, section: indexPath.section)
            tableView.cellForRow(at: selectedTileServerIndexPath)?.accessoryType = .none
            
        
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            preferences.tileServerInt = indexPath.row
            
        
            self.delegate?.didUpdateTileServer((indexPath as NSIndexPath).row)
        }
        
     
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
