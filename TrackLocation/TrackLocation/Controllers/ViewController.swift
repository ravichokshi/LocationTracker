//
//  ViewController.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import UIKit

import SpriteKit
import CoreLocation
import MapKit
import CoreGPX



let kPurpleButtonBackgroundColor: UIColor =  UIColor(red: 146.0/255.0, green: 166.0/255.0, blue: 218.0/255.0, alpha: 0.90)


let kGreenButtonBackgroundColor: UIColor = UIColor(red: 142.0/255.0, green: 224.0/255.0, blue: 102.0/255.0, alpha: 0.90)


let kRedButtonBackgroundColor: UIColor =  UIColor(red: 244.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.90)


let kBlueButtonBackgroundColor: UIColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 0.90)


let kDisabledBlueButtonBackgroundColor: UIColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 0.10)


let kDisabledRedButtonBackgroundColor: UIColor =  UIColor(red: 244.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.10)


let kWhiteBGColor: UIColor = UIColor(red: 254.0/255.0, green: 254.0/255.0, blue: 254.0/255.0, alpha: 0.90)

let kClearBGColor: UIColor = UIColor.clear

let kDeleteWaypointAccesoryButtonTag = 666


let kEditWaypointAccesoryButtonTag = 333


let kNotGettingLocationText = "Not getting location"


let kUnknownAccuracyText = "±···"


let kUnknownSpeedText = "·.··"


let kButtonSmallSize: CGFloat = 48.0


let kButtonLargeSize: CGFloat = 96.0


let kButtonSeparation: CGFloat = 6.0


let kSignalAccuracy6 = 6.0

let kSignalAccuracy5 = 11.0

let kSignalAccuracy4 = 31.0

let kSignalAccuracy3 = 51.0

let kSignalAccuracy2 = 101.0

let kSignalAccuracy1 = 201.0


class ViewController: UIViewController, UIGestureRecognizerDelegate  {
    

    var followUser: Bool = true {
        didSet {
            if followUser {
                print("followUser=true")
                followUserButton.setImage(UIImage(named: "follow_user_high"), for: UIControl.State())
                map.setCenter((map.userLocation.coordinate), animated: true)
                
            } else {
                print("followUser=false")
                followUserButton.setImage(UIImage(named: "follow_user"), for: UIControl.State())
            }
            
        }
    }
    
 
    var followUserBeforePinchGesture = true
    
    

    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2
        manager.headingFilter = 1
        manager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        }
        return manager
    }()
    

    var map: GPXMapView
    

    let mapViewDelegate = MapViewDelegate()
    

    var stopWatch = StopWatch()
    

    var lastGpxFilename: String = ""
    

    var wasSentToBackground: Bool = false
    

    var isDisplayingLocationServicesDenied: Bool = false
    

    var hasWaypoints: Bool = false {

        didSet {
            if hasWaypoints {
                saveButton.backgroundColor = kBlueButtonBackgroundColor
                resetButton.backgroundColor = kRedButtonBackgroundColor
            }
        }
    }
    
    

    enum GpxTrackingStatus {
        

        case notStarted
        
    
        case tracking
        
  
        case paused
    }
    

    var gpxTrackingStatus: GpxTrackingStatus = GpxTrackingStatus.notStarted {
        didSet {
            print("gpxTrackingStatus changed to \(gpxTrackingStatus)")
            switch gpxTrackingStatus {
            case .notStarted:
                print("switched to non started")
           
//                trackerButton.setTitle("Start Tracking", for: UIControl.State())
//                trackerButton.backgroundColor = kGreenButtonBackgroundColor
                
                trackerButton.setImage(UIImage(named: "start"), for: .normal)
       
                saveButton.backgroundColor = kDisabledBlueButtonBackgroundColor
                resetButton.backgroundColor = kDisabledRedButtonBackgroundColor
               
                stopWatch.reset()
                timeLabel.text = stopWatch.elapsedTimeString
                
                map.clearMap()
                lastGpxFilename = ""
                
                map.coreDataHelper.clearAll()
                map.coreDataHelper.deleteLastFileNameFromCoreData()
                
            
                
              
                
            case .tracking:
                print("switched to tracking mode")
       
//                trackerButton.setTitle("Stop", for: UIControl.State())
//                trackerButton.backgroundColor = kPurpleButtonBackgroundColor
                trackerButton.setImage(UIImage(named: "stop"), for: .normal)
                saveButton.backgroundColor = kBlueButtonBackgroundColor
                resetButton.backgroundColor = kRedButtonBackgroundColor
                addPinAtMyLocation()
                self.stopWatch.start()
            
            case .paused:
                print("switched to paused mode")
//
//                self.trackerButton.setTitle("Resume", for: UIControl.State())
//                self.trackerButton.backgroundColor = kGreenButtonBackgroundColor
//
//                saveButton.backgroundColor = kBlueButtonBackgroundColor
//                resetButton.backgroundColor = kRedButtonBackgroundColor
//
                
                
//
             //   self.map.startNewTrackSegment()
                
                 
               
                
                saveButtonTapped()
            }
        }
    }
    
  
    var lastLocation: CLLocation?
    
    var appTitleLabel: UILabel
    
   
//    var signalImageView: UIImageView
//
//
//    var signalAccuracyLabel: UILabel
    
  
    var coordsLabel: UILabel
    

    var timeLabel: UILabel
    
  
    var speedLabel: UILabel
    
    
    var bottomContainerView: UIView
    
   
  
   
    var useImperial = false
    
   
    var followUserButton: UIButton
    

    var newPinButton: UIButton
    
    var folderButton: UIButton
    

    var preferencesButton: UIButton
    
    
    var shareButton: UIButton
    
  
    let shareActivityIndicator: UIActivityIndicatorView
    
 
    var resetButton: UIButton
    
    
    var trackerButton: UIButton
    
   
   
    var saveButton: UIButton
    
 
    let signalImage0 = UIImage(named: "signal0")

    let signalImage1 = UIImage(named: "signal1")

    let signalImage2 = UIImage(named: "signal2")
  
    let signalImage3 = UIImage(named: "signal3")

    let signalImage4 = UIImage(named: "signal4")
  
    let signalImage5 = UIImage(named: "signal5")
    
    let signalImage6 = UIImage(named: "signal6")
    

    required init(coder aDecoder: NSCoder) {
        self.map = GPXMapView(coder: aDecoder)!
        
        self.appTitleLabel = UILabel(coder: aDecoder)!
     
        self.coordsLabel = UILabel(coder: aDecoder)!
        
        self.timeLabel = UILabel(coder: aDecoder)!
        self.speedLabel = UILabel(coder: aDecoder)!
      
        
        self.followUserButton = UIButton(coder: aDecoder)!
        self.newPinButton = UIButton(coder: aDecoder)!
        self.folderButton = UIButton(coder: aDecoder)!
        self.resetButton = UIButton(coder: aDecoder)!
        
        self.preferencesButton = UIButton(coder: aDecoder)!
        self.shareButton = UIButton(coder: aDecoder)!
        
        self.trackerButton = UIButton(coder: aDecoder)!
        self.saveButton = UIButton(coder: aDecoder)!
        
        self.shareActivityIndicator = UIActivityIndicatorView(coder: aDecoder)
        
        self.bottomContainerView =  UIView(coder: aDecoder)!
     
       
        super.init(coder: aDecoder)!
    }
    
  
    deinit {
        print("*** deinit")
        removeNotificationObservers()
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        stopWatch.delegate = self
        
        map.coreDataHelper.retrieveFromCoreData()
        
      
        var isIPhoneX = false
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("device: IPHONE 5,5S,5C")
            case 1334:
                print("device: IPHONE 6,7,8 IPHONE 6S,7S,8S ")
            case 1920, 2208:
                print("device: IPHONE 6PLUS, 6SPLUS, 7PLUS, 8PLUS")
            case 2436:
                print("device: IPHONE X, IPHONE XS")
                isIPhoneX = true
            case 2688:
                print("device: IPHONE XS_MAX")
                isIPhoneX = true
            case 1792:
                print("device: IPHONE XR")
                isIPhoneX = true
            default:
                print("UNDETERMINED")
            }
        }
        
      
        map.autoresizesSubviews = true
        map.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.autoresizesSubviews = true
        self.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        
        map.delegate = mapViewDelegate
        map.showsUserLocation = true
        let mapH: CGFloat = self.view.bounds.size.height - (isIPhoneX ? 0.0 : 20.0)
        map.frame = CGRect(x: 0.0, y: (isIPhoneX ? 0.0 : 20.0), width: self.view.bounds.size.width, height: mapH)
        map.isZoomEnabled = true
        map.isRotateEnabled = true
      
        map.compassRect = CGRect(x:  18, y: isIPhoneX ? 105.0 : 70.0 , width: 36, height: 36)
        
       
//        map.addGestureRecognizer(
//            UILongPressGestureRecognizer(target: self, action: #selector(ViewController.addPinAtTappedLocation(_:)))
//        )
        
    
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.stopFollowingUser(_:)))
//        panGesture.delegate = self
//        map.addGestureRecognizer(panGesture)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
     
        map.tileServer = Preferences.shared.tileServer
        map.useCache = Preferences.shared.useCache
        useImperial = Preferences.shared.useImperial
        
        
     
        let center = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: center, span: span)
        map.setRegion(region, animated: true)
        self.view.addSubview(map)
        
        addNotificationObservers()
        
      
        let font36 = UIFont(name: Font_Bold, size: 36.0)
        let font18 = UIFont(name: Font_Bold, size: 18.0)
        let font12 = UIFont(name: Font_Bold, size: 12.0)
        
       
        let appTitleW: CGFloat = self.view.frame.width
        let appTitleH: CGFloat = 14.0
        let appTitleX: CGFloat = 0
        let appTitleY: CGFloat = isIPhoneX ? 40.0 : 20.0
        appTitleLabel.frame = CGRect(x:appTitleX, y: appTitleY, width: appTitleW, height: appTitleH)
        appTitleLabel.text = "  Location Tracker"
        appTitleLabel.textAlignment = .left
        appTitleLabel.font = UIFont.boldSystemFont(ofSize: 10)
     
        appTitleLabel.textColor = UIColor.white
        appTitleLabel.backgroundColor = UIColor(red: 58.0/255.0, green: 57.0/255.0, blue: 54.0/255.0, alpha: 0.80)
        appTitleLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        self.view.addSubview(appTitleLabel)
        
      
        coordsLabel.frame = CGRect(x: self.map.frame.width - 305, y: appTitleY, width: 300, height: 12)
        coordsLabel.textAlignment = .right
        coordsLabel.font = font12
        coordsLabel.textColor = UIColor.white
        coordsLabel.text = kNotGettingLocationText
        coordsLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        self.view.addSubview(coordsLabel)
        
     
        let iPhoneXdiff: CGFloat  = isIPhoneX ? 40 : 0
       
        timeLabel.frame = CGRect(x: self.map.frame.width - 160, y: 20 + iPhoneXdiff, width: 150, height: 40)
        timeLabel.textAlignment = .right
        timeLabel.font = font36
        timeLabel.text = "00:00"
        timeLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
       
        map.addSubview(timeLabel)
        
//    
//        speedLabel.frame = CGRect(x: self.map.frame.width - 160,  y: 20 + 36 + iPhoneXdiff, width: 150, height: 20)
//        speedLabel.textAlignment = .right
//        speedLabel.font = font18
//        speedLabel.text = 0.00.toSpeed(useImperial: useImperial)
//        speedLabel.autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
      
     //   map.addSubview(speedLabel)
        
     
        
     
//        preferencesButton.frame = CGRect(x: 5 + 10 + 48, y: 14 + 5 + 8  + iPhoneXdiff, width: 32, height: 32)
//        preferencesButton.setImage(UIImage(named: "prefs"), for: UIControl.State())
//        preferencesButton.setImage(UIImage(named: "prefs_high"), for: .highlighted)
//        preferencesButton.addTarget(self, action: #selector(ViewController.openPreferencesTableViewController), for: .touchUpInside)
//        preferencesButton.autoresizingMask = [.flexibleRightMargin]
//
//        preferencesButton.isHidden = true
//        map.addSubview(preferencesButton)
        
     
//        shareButton.frame =  CGRect(x: 5 + 10 + 48, y: 14 + 5 + 8  + iPhoneXdiff, width: 32, height: 32) //CGRect(x: 5 + 10 + 48 * 2, y: 14 + 5 + 8  + iPhoneXdiff, width: 32, height: 32)
//        shareButton.setImage(UIImage(named: "share"), for: UIControl.State())
//        shareButton.setImage(UIImage(named: "share_high"), for: .highlighted)
//        shareButton.addTarget(self, action: #selector(ViewController.openShare), for: .touchUpInside)
//        shareButton.autoresizingMask = [.flexibleRightMargin]
//
//        map.addSubview(shareButton)
   
      
     
      
        
        bottomContainerView.frame = CGRect(x: 80, y:self.view.frame.height - 100, width: self.view.frame.width - 160, height: 60)
        bottomContainerView.backgroundColor = kWhiteBGColor
        bottomContainerView.addShadow()
        map.addSubview(bottomContainerView)
        
        let yCenterForButtons: CGFloat = map.frame.height - kButtonLargeSize/2 - 5
        let trackerW: CGFloat = kButtonSmallSize
        let trackerH: CGFloat = kButtonSmallSize
        let trackerX: CGFloat = self.map.frame.width/2 - 0.0
        let trackerY: CGFloat = yCenterForButtons
        trackerButton.frame = CGRect(x: 0, y:0, width: trackerW, height: trackerH)
        trackerButton.center = CGPoint(x: trackerX, y: trackerY)
        trackerButton.layer.cornerRadius = trackerW/2
        //trackerButton.setTitle("Start Tracking", for: UIControl.State())
        trackerButton.setImage(UIImage(named: "start"), for: .normal)
        trackerButton.backgroundColor = kGreenButtonBackgroundColor
        trackerButton.addTarget(self, action: #selector(ViewController.trackerButtonTapped), for: .touchUpInside)
        trackerButton.isHidden = false
        trackerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        trackerButton.titleLabel?.numberOfLines = 2
        trackerButton.titleLabel?.textAlignment = .center
        trackerButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        trackerButton.addShadow()
       
    
        map.addSubview(trackerButton)
        
     
        
       
        let followW: CGFloat = kButtonSmallSize
        let followH: CGFloat = kButtonSmallSize
        let followX: CGFloat = trackerX - trackerW/2 - kButtonSeparation - followW/2
        let followY: CGFloat = yCenterForButtons
        followUserButton.frame = CGRect(x: 0, y: 0, width: followW, height: followH)
        followUserButton.center = CGPoint(x: followX, y: followY)
        followUserButton.layer.cornerRadius = followW/2
        followUserButton.backgroundColor = kClearBGColor
      
        followUserButton.setImage(UIImage(named: "follow_user_high"), for: UIControl.State())
        followUserButton.setImage(UIImage(named: "follow_user_high"), for: .highlighted)
        followUserButton.addTarget(self, action: #selector(ViewController.followButtonTroggler), for: .touchUpInside)
        followUserButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
        map.addSubview(followUserButton)
        
        let folderW: CGFloat = kButtonSmallSize
        let folderH: CGFloat = kButtonSmallSize
        let folderX: CGFloat = trackerX + trackerW/2 + kButtonSeparation + folderW/2
        let folderY: CGFloat = yCenterForButtons
        folderButton.frame = CGRect(x: 0, y: 0, width: folderW, height: folderH)
        folderButton.center = CGPoint(x: folderX, y: folderY)
        folderButton.setImage(UIImage(named: "folder"), for: UIControl.State())
        folderButton.setImage(UIImage(named: "folderHigh"), for: .highlighted)
        folderButton.addTarget(self, action: #selector(ViewController.openFolderViewController), for: .touchUpInside)
        folderButton.backgroundColor = .clear//kWhiteBGColor
        folderButton.layer.cornerRadius = 24
        folderButton.autoresizingMask = [.flexibleRightMargin]
        map.addSubview(folderButton)
        
//        let newPointW: CGFloat = kButtonSmallSize
//        let newPointH: CGFloat = kButtonSmallSize
//        let newPointX: CGFloat = trackerX + trackerW/2 + kButtonSeparation + newPointW/2
//        let newPointY: CGFloat = yCenterForButtons
//        newPinButton.frame = CGRect(x: 0, y: 0, width: newPointW, height: newPointH)
//        newPinButton.center = CGPoint(x: newPointX, y: newPointY)
//        newPinButton.layer.cornerRadius = newPointW/2
//        newPinButton.backgroundColor = kClearBGColor
//        newPinButton.setImage(UIImage(named: "addPin"), for: UIControl.State())
//        newPinButton.setImage(UIImage(named: "addPinHigh"), for: .highlighted)
//        newPinButton.addTarget(self, action: #selector(ViewController.addPinAtMyLocation), for: .touchUpInside)
//        newPinButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
//
//        map.addSubview(newPinButton)
        

    }
    
    
    func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(ViewController.didEnterBackground),
                                       name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        
        notificationCenter.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        
     
        notificationCenter.addObserver(self, selector: #selector(loadRecoveredFile(_:)), name: .loadRecoveredFile, object: nil)
    }
    
    
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
   
    @objc func presentReceivedFile(_ notification: Notification) {
        
        guard let fileName = notification.userInfo?["fileName"] as? String? else { return }
        
      
        let controller = UIAlertController(title: "File Received from Apple Watch", message: "Received file: \"\(fileName ?? "")\"", preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default) {
            (action) in
            print("ViewController:: Presented file received message from WatchConnectivity Session")
        }
        
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
    }
    
   
    func defaultFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy-HHmm"
        print("fileName:" + dateFormatter.string(from: Date()))
        return dateFormatter.string(from: Date())
    }
    
    @objc func loadRecoveredFile(_ notification: Notification) {
        guard let root = notification.userInfo?["recoveredRoot"] as? GPXRoot else {
            return
        }
        guard let fileName = notification.userInfo?["fileName"] as? String else {
            return
        }
        
        lastGpxFilename = fileName
       
        self.map.coreDataHelper.add(toCoreData: fileName)
   
        self.stopWatch.reset()
    
        self.map.continueFromGPXRoot(root)
   
        self.followUser = false
      
        self.map.regionToGPXExtent()
        self.gpxTrackingStatus = .paused
        
      
    
    }
 
    @objc func applicationDidBecomeActive() {
        print("viewController:: applicationDidBecomeActive wasSentToBackground: \(wasSentToBackground) locationServices: \(CLLocationManager.locationServicesEnabled())")
        
       
        if !wasSentToBackground {
            return
        }
        checkLocationServicesStatus()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
  
    @objc func didEnterBackground() {
        wasSentToBackground = true
        print("viewController:: didEnterBackground")
        if gpxTrackingStatus != .tracking {
            locationManager.stopUpdatingLocation()
        }
    }
    

    @objc func applicationWillTerminate() {
        print("viewController:: applicationWillTerminate")
        GPXFileManager.removeTemporaryFiles()
        if gpxTrackingStatus == .notStarted {
            map.coreDataHelper.deleteAllPointsFromCoreData()
        }
    }
    
  
    @objc func openFolderViewController() {
        print("openFolderViewController")
        let vc = GPXFilesTableVC(nibName: nil, bundle: nil)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true) { () -> Void in }
    }
    
//
//    @objc func openAboutViewController() {
//        let vc = AboutViewController(nibName: nil, bundle: nil)
//        let navController = UINavigationController(rootViewController: vc)
//        self.present(navController, animated: true) { () -> Void in }
//    }
//
    @objc func openPreferencesTableViewController() {
        print("openPreferencesTableViewController")
        let vc = PreferencesTableViewController(style: .grouped)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true) { () -> Void in }
    }
    
   
    @objc func openShare() {
        print("ViewController: Share Button tapped")
        
      
        DispatchQueue.global(qos: .utility).async {
         
            DispatchQueue.main.sync {
                self.shouldShowShareActivityIndicator(true)
            }
            
          
            let filename =  self.lastGpxFilename.isEmpty ? self.defaultFilename() : self.lastGpxFilename
            let gpxString: String = self.map.exportToGPXString()
            let tmpFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(filename).gpx")
            GPXFileManager.saveToURL(tmpFile, gpxContents: gpxString)
           
            DispatchQueue.main.sync {
               
                let activityViewController = UIActivityViewController(activityItems: [tmpFile], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.shareButton
                activityViewController.popoverPresentationController?.sourceRect = self.shareButton.bounds
                self.present(activityViewController, animated: true, completion: nil)
                self.shouldShowShareActivityIndicator(false)
            }
            
        }
    }
    
 
    func shouldShowShareActivityIndicator(_ isTrue: Bool) {
      
        shareActivityIndicator.color = .black
        shareActivityIndicator.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        shareActivityIndicator.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        if isTrue {
           
            UIView.transition(with: self.shareButton, duration: 0.35, options: [.transitionCrossDissolve], animations: {
                self.shareButton.addSubview(self.shareActivityIndicator)
            }, completion: nil)
            
            shareActivityIndicator.startAnimating()
            shareButton.setImage(nil, for: UIControl.State())
            shareButton.isUserInteractionEnabled = false
        }
        else {
         
            UIView.transition(with: self.shareButton, duration: 0.35, options: [.transitionCrossDissolve], animations: {
                self.shareActivityIndicator.removeFromSuperview()
            }, completion: nil)
            
            shareActivityIndicator.stopAnimating()
            shareButton.setImage(UIImage(named: "share"), for: UIControl.State())
            shareButton.isUserInteractionEnabled = true
        }
    }
    
    @objc func stopFollowingUser(_ gesture: UIPanGestureRecognizer) {
        if self.followUser {
            self.followUser = false
        }
    }
    
   
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
  
    @objc func addPinAtTappedLocation(_ gesture: UILongPressGestureRecognizer) {
        if  gesture.state == UIGestureRecognizer.State.began {
            print("Adding Pin map Long Press Gesture")
            let point: CGPoint = gesture.location(in: self.map)
            map.addWaypointAtViewPoint(point)
        
            self.hasWaypoints = true
        }
    }
    
  
    func pinchGesture(_ gesture: UIPinchGestureRecognizer) {
        print("pinchGesture")
      
    }
    
 
    @objc func addPinAtMyLocation() {
        print("Adding Pin at my location")
        let altitude = map.userLocation.location?.altitude
        let waypoint = GPXWaypoint(coordinate: map.userLocation.coordinate, altitude: altitude)
        map.addWaypoint(waypoint)
        map.coreDataHelper.add(toCoreData: waypoint)
        self.hasWaypoints = true
    }
    
   
    @objc func followButtonTroggler() {
        
        self.followUser = !self.followUser
        if self.followUser == true {
            let alert = UIAlertController(title: "", message: "Follow user on", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            // change to desired number of seconds (in this case 5 seconds)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                alert.dismiss(animated: true, completion: nil)
            }
        }else {
            let alert = UIAlertController(title: "", message: "Follow user off", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            // change to desired number of seconds (in this case 5 seconds)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc func resetButtonTapped() {
        self.gpxTrackingStatus = .notStarted
    }
    
    
    
    @objc func trackerButtonTapped() {
        print("startGpxTracking::")
        switch gpxTrackingStatus {
        case .notStarted:
            gpxTrackingStatus = .tracking
        case .tracking:
            gpxTrackingStatus = .paused
        case .paused:
            //set to tracking
            gpxTrackingStatus = .paused
        }
    }
  
    @objc func saveButtonTapped() {
        print("save Button tapped")
      
        if (gpxTrackingStatus == .notStarted) && !self.hasWaypoints {
            return
        }
        else if (gpxTrackingStatus == .paused) {
        
        }
        let alertController = UIAlertController(title: "Save as", message: "Enter session name", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.clearButtonMode = .always
            textField.text = self.lastGpxFilename.isEmpty ? self.defaultFilename() : self.lastGpxFilename
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            let filename = (alertController.textFields?[0].text!.utf16.count == 0) ? self.defaultFilename() : alertController.textFields?[0].text
            print("Save File \(String(describing: filename))")
            self.addPinAtMyLocation()
           self.stopWatch.stop()
            let gpxString = self.map.exportToGPXString()
            GPXFileManager.save(filename!, gpxContents: gpxString)
            self.lastGpxFilename = filename!
            self.map.coreDataHelper.deleteLastFileNameFromCoreData()
            self.map.coreDataHelper.add(toCoreData: filename!)
            
            self.resetButtonTapped()
        }
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { (action) in
            
            self.resetButtonTapped()
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
         
            self.map.startNewTrackSegment()
            
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        print("didReceiveMemoryWarning");
        super.didReceiveMemoryWarning()
        
    }
    
  
    func checkLocationServicesStatus() {
       
        if !CLLocationManager.locationServicesEnabled() {
            displayLocationServicesDisabledAlert()
            return
        }
      
        if !([.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())) {
            displayLocationServicesDeniedAlert()
            return
        }
    }
 
    func displayLocationServicesDisabledAlert() {
        
        let alertController = UIAlertController(title: "Location services disabled", message: "Go to settings and enable location.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
    
    
    
    func displayLocationServicesDeniedAlert() {
        if isDisplayingLocationServicesDenied {
            return
        }
        let alertController = UIAlertController(title: "Access to location denied", message: "On Location settings, allow always access to location for GPX Tracker ", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        isDisplayingLocationServicesDenied = false
    }
    
}


extension ViewController: StopWatchDelegate {
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String) {
        timeLabel.text = elapsedTimeString
    }
}


extension ViewController: PreferencesTableViewControllerDelegate {
  
    func didUpdateTileServer(_ newGpxTileServer: Int) {
        print("PreferencesTableViewControllerDelegate:: didUpdateTileServer: \(newGpxTileServer)")
        self.map.tileServer = GPXTileServer(rawValue: newGpxTileServer)!
    }
    
  
    func didUpdateUseCache(_ newUseCache: Bool) {
        print("PreferencesTableViewControllerDelegate:: didUpdateUseCache: \(newUseCache)")
        self.map.useCache = newUseCache
    }
    
   
    func didUpdateUseImperial(_ newUseImperial: Bool) {
        print("PreferencesTableViewControllerDelegate:: didUpdateUseImperial: \(newUseImperial)")
        useImperial = newUseImperial
      
      
        speedLabel.text = kUnknownSpeedText
        
    }}

extension ViewController: GPXFilesTableVCDelegate {
   
    func loadGPXFileWithName(_ gpxFilename: String, gpxRoot: GPXRoot) {
     
        self.resetButtonTapped()
       
        lastGpxFilename = gpxFilename
        
        self.map.coreDataHelper.add(toCoreData: gpxFilename)
       
        self.stopWatch.reset()
       
        self.map.importFromGPXRoot(gpxRoot)
      
        self.followUser = false
       
        self.map.regionToGPXExtent()
        self.gpxTrackingStatus = .paused
        
    
        
    }
}


extension ViewController: CLLocationManagerDelegate {
    
  
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        coordsLabel.text = kNotGettingLocationText
      
        let locationError = error as? CLError
        switch locationError?.code {
        case CLError.locationUnknown:
            print("Location Unknown")
        case CLError.denied:
            print("Access to location services denied. Display message")
            checkLocationServicesStatus()
        case CLError.headingFailure:
            print("Heading failure")
        default:
            print("Default error")
        }
        
    }
    
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        let newLocation = locations.first!
        print("isUserLocationVisible: \(map.isUserLocationVisible) showUserLocation: \(map.showsUserLocation)")
        print("didUpdateLocation: received \(newLocation.coordinate) hAcc: \(newLocation.horizontalAccuracy) vAcc: \(newLocation.verticalAccuracy) floor: \(newLocation.floor?.description ?? "''") map.userTrackingMode: \(map.userTrackingMode.rawValue)")
        
       
        //let hAcc = newLocation.horizontalAccuracy
      
       
        
    
//        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
//        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
     
        
       
        if followUser {
            map.setCenter(newLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .tracking {
            print("didUpdateLocation: adding point to track (\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude))")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
           
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
   //     print("ViewController::didUpdateHeading \(newHeading.trueHeading)")
        map.updateHeading(newHeading)
        
    }
}


extension Notification.Name {
    static let loadRecoveredFile = Notification.Name("loadRecoveredFile")
}
extension UIView {
    
    func addShadow(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 1.0
        self.layer.shadowOffset =  CGSize(width: 0.0, height: 0.0)
    }
}
