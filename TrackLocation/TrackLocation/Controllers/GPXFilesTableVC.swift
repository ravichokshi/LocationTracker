//
//  GPXFilesTableViewController.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//


import Foundation
import UIKit
import CoreGPX
import MessageUI

import CoreLocation

let kNoFiles = "No gpx files found"


class GPXFilesTableVC: UITableViewController, UINavigationBarDelegate {
    
   
    var dataList: NSMutableArray = [kNoFiles]
    
  
    var isGpxFilesFound = false;
    

    var selectedRowIndex = -1

    weak var delegate: GPXFilesTableVCDelegate?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        self.title = "Your GPX Files"
        
      
        addNotificationObservers()
        
       
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(GPXFilesTableVC.closeGPXFilesTableVC))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        
      
        let list: [GPXFileInfo] = GPXFileManager.fileList
        if list.count != 0 {
            self.dataList.removeAllObjects()
            self.dataList.addObjects(from: list)
            self.isGpxFilesFound = true
        }
    }
    
   
    deinit {
        removeNotificationObservers()
    }
    
   
    @objc func closeGPXFilesTableVC() {
        print("closeGPXFIlesTableViewController()")
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
     
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    
  
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isGpxFilesFound
    }
    
    
  
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isGpxFilesFound {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
          
            let gpxFileInfo = dataList.object(at: (indexPath as NSIndexPath).row) as! GPXFileInfo
         
            cell.textLabel?.text = gpxFileInfo.fileName
            cell.detailTextLabel?.text =
            "last saved \(gpxFileInfo.modifiedDatetimeAgo) (\(gpxFileInfo.fileSizeHumanised))"
            cell.detailTextLabel?.textColor = UIColor.darkGray
            return cell
        } else {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.text = dataList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
            return cell
        }
    }
    
    
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sheet = UIAlertController(title: nil, message: "Select option", preferredStyle: .actionSheet)
        let mapOption = UIAlertAction(title: "Load in Map", style: .default) { action in
            self.actionLoadFileAtIndex(indexPath.row)
        }
        let shareOption = UIAlertAction(title: "Share", style: .default) { action in
            self.actionShareFileAtIndex(indexPath.row, tableView: tableView, indexPath: indexPath)
        }
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.actionSheetCancel(sheet)
        }
        
        let deleteOption = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.actionDeleteFileAtIndex(indexPath.row)
        }
        
        sheet.addAction(mapOption)
        sheet.addAction(shareOption)
        sheet.addAction(cancelOption)
        sheet.addAction(deleteOption)
        
        var cellRect = tableView.rectForRow(at: indexPath)
        cellRect.origin = CGPoint(x: 0, y: 0)
        sheet.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        sheet.popoverPresentationController?.sourceRect = cellRect
        
        self.present(sheet, animated: true) {
            print("Loaded actionSheet")
        }
    }
    
   
    override func tableView(_ tableView: UITableView,
                            shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return isGpxFilesFound
    }
    
 
    internal func fileListObjectTitle(_ rowIndex: Int) -> String {
        return (dataList.object(at: rowIndex) as! GPXFileInfo).fileName
    }
    
    
    internal func actionSheetCancel(_ actionSheet: UIAlertController) {
        print("ActionSheet cancel")
    }
    
    
   
    internal func actionDeleteFileAtIndex(_ rowIndex: Int) {
        
        guard let fileURL: URL = (dataList.object(at: rowIndex) as? GPXFileInfo)?.fileURL else {
            print("GPXFileTableViewController:: actionDeleteFileAtIndex: failed to get fileURL")
            return
        }
        GPXFileManager.removeFileFromURL(fileURL)
        
      
        dataList.removeObject(at: rowIndex)
        let indexPath = IndexPath(row: rowIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        tableView.reloadData()
    }
    
    
   
    internal func actionLoadFileAtIndex(_ rowIndex: Int) {
        DispatchQueue.global(qos: .utility).async {
            DispatchQueue.main.sync {
                self.displayLoadingFileAlert(true)
            }
            
            guard let gpxFileInfo: GPXFileInfo = (self.dataList.object(at: rowIndex) as? GPXFileInfo) else {
                print("GPXFileTableViewController:: actionLoadFileAtIndex(\(rowIndex)): failed to get fileURL")
                self.displayLoadingFileAlert(false)
                return
            }
            
            print("Load gpx File: \(gpxFileInfo.fileName)")
            guard let gpx = GPXParser(withURL: gpxFileInfo.fileURL)?.parsedData() else {
                print("GPXFileTableViewController:: actionLoadFileAtIndex(\(rowIndex)): failed to parse GPX file")
                self.displayLoadingFileAlert(false)
                return
            }
            
            DispatchQueue.main.sync {
                self.displayLoadingFileAlert(false) {
                    self.delegate?.loadGPXFileWithName(gpxFileInfo.fileName, gpxRoot: gpx)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
  
    func displayLoadingFileAlert(_ loading: Bool, completion: (() -> Void)? = nil) {
     
        let alertController = UIAlertController(title: "Loading GPX File...", message: nil, preferredStyle: .alert)
        let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 35, y: 30, width: 32, height: 32))
        activityIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .black
        
        if loading {
            activityIndicatorView.startAnimating()
            alertController.view.addSubview(activityIndicatorView)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            activityIndicatorView.stopAnimating()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
      
        guard let completion = completion else { return }
        completion()
    }
    
    
   
    internal func actionShareFileAtIndex(_ rowIndex: Int, tableView: UITableView, indexPath: IndexPath) {
        guard let gpxFileInfo: GPXFileInfo = (dataList.object(at: rowIndex) as? GPXFileInfo) else {
            print("Unable to get filename at row \(rowIndex), cannot respond to \(type(of: self))didSelectRowAt")
            return
        }
        print("GPXTableViewController: actionShareFileAtIndex")
        
        let activityViewController = UIActivityViewController(activityItems: [gpxFileInfo.fileURL], applicationActivities: nil)
        
        var cellRect = tableView.rectForRow(at: indexPath)
        cellRect.origin = CGPoint(x: 0, y: 0)
        activityViewController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        activityViewController.popoverPresentationController?.sourceRect = cellRect
        
     
        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
              
                print("actionShareAtIndex: Cancelled")
                return
            }
          
            print("actionShareFileAtIndex: User completed activity")
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}

extension GPXFilesTableVC {
    
  
    func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(reloadTableData),
                                       name: .didReceiveFileFromURL, object: nil)
      
    }
   
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
   
    @objc func reloadTableData() {
        print("TableViewController: reloadTableData")
        let list: [GPXFileInfo] = GPXFileManager.fileList
        if self.dataList.count < list.count && list.count != 0 {
            self.dataList.removeAllObjects()
            self.dataList.addObjects(from: list)
            self.isGpxFilesFound = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}
