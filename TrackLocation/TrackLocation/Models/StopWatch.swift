//
//  StopWatch.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
/// Posible status of the stop watch
enum StopWatchStatus {
    

    case started

    case stopped
}



class StopWatch: NSObject {
    
  
    var tmpElapsedTime: TimeInterval = 0.0
    
  
    var startedTime: TimeInterval = 0.0
    
  
    var status: StopWatchStatus
    
   
    var timeInterval: TimeInterval = 1.00
    
  
    var timer = Timer()
    
    
    weak var delegate: StopWatchDelegate?
    
    
    override init() {
        self.tmpElapsedTime = 0.0
        self.status = StopWatchStatus.stopped
        super.init()
    }
    
   
    func start() {
        print("StopWatch: started")
        self.status = .started
        self.startedTime = Date.timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(StopWatch.updateElapsedTime), userInfo: nil, repeats: true)
    }
    
   
    func stop() {
        print("StopWatch: stopped")
        self.status = .stopped
       
        let currentTime = Date.timeIntervalSinceReferenceDate
        let diff = currentTime - startedTime
        tmpElapsedTime = tmpElapsedTime + diff
        timer.invalidate()
    }
    
   
    func reset() {
        print("StopWatch: reset")
        timer.invalidate()
        self.tmpElapsedTime = 0.0
        self.startedTime = Date.timeIntervalSinceReferenceDate
        self.status = .stopped
    }
    
  
    var elapsedTime: TimeInterval {
        get {
            if self.status == .stopped {
                return self.tmpElapsedTime
            }
            let diff = Date.timeIntervalSinceReferenceDate - startedTime
            return tmpElapsedTime + diff
        }
    }
    
 
    var elapsedTimeString: String {
        get {
            var tmpTime: TimeInterval = self.elapsedTime
           
            
            let hours = UInt32(tmpTime / 3600.0)
            tmpTime -= (TimeInterval(hours) * 3600)
            
            let minutes = UInt32(tmpTime / 60.0)
            tmpTime -= (TimeInterval(minutes) * 60)
            
         
            let seconds = UInt32(tmpTime)
            tmpTime -= TimeInterval(seconds)
            
           
            let strHours = hours > 0 ? String(hours) + "h" : ""
         
            
            let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
            let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
            
           
            return "\(strHours)\(strMinutes):\(strSeconds)"
        }
    }
    
 
    @objc func updateElapsedTime() {
        self.delegate?.stopWatch(self, didUpdateElapsedTimeString: self.elapsedTimeString)
    }
}
