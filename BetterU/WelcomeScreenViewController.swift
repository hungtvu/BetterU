//
//  WelcomeScreenViewController.swift
//  BetterU
//
//  Created by Travis Lu on 4/4/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import VideoSplashKit

class WelcomeScreenViewController: VideoSplashViewController {
    
    @IBOutlet var signUp: UIButton!
    @IBOutlet var LogIn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        LogIn.layer.cornerRadius = 5
        //signUp.layer.cornerRadius = 5
        let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("background", ofType: "mp4")!)
        self.videoFrame = view.frame
        self.fillMode = .ResizeAspectFill
        self.alwaysRepeat = true
        self.sound = true
        self.startTime = 12.0
        self.alpha = 0.7
        self.backgroundColor = UIColor.blackColor()
        self.contentURL = url
        self.restartForeground = true
    }
    @IBAction func logInPressed(sender: AnyObject) {
        performSegueWithIdentifier("LogIn", sender: nil)
        
    }
}