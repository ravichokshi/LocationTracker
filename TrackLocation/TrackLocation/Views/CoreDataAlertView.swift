//
//  CoreDataAlertView.swift
//  TrackLocation
//
//  Created by Ravi Chokshi on 26/07/19.
//  Copyright © 2019 Ravi Chokshi. All rights reserved.
//

import Foundation
import UIKit
struct CoreDataAlertView {
    

    func showActionSheet(_ alertController: UIAlertController) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        
        guard let windowLevel = UIApplication.shared.windows.last?.windowLevel else { return }
        
        window.windowLevel = windowLevel + 1
        window.makeKeyAndVisible()
        
        if let popoverController = alertController.popoverPresentationController {
            guard let view = window.rootViewController?.view else { return }
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        window.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
