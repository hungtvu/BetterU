//
//  CustomTabBarController.swift
//  BetterU
//
//  Created by Hung Vu on 3/31/2016.
//  Copyright (c) 2016 BetterU LLC. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    // Custom tab bar to add over the default tab bar
    var customTabBar: UITabBar!
    
    // Tab bar items
    var itemA: UITabBarItem!
    var itemB: UITabBarItem!
    var hiddenItem: UITabBarItem! // hidden by a large menu button
    var itemC: UITabBarItem!
    var moreItem: UITabBarItem! // to demonstrate "more" functionality
    var itemD: UITabBarItem!
    //var itemE: UITabBarItem!
    
    // View controllers linked to each tab bar item
    // Note these are created in the storyboard without segues
    // They are referenced by a unique storyboard ID
    var vcA: UIViewController!
    var vcB: UIViewController!
    var vcHidden: UIViewController!
    var vcC: UIViewController!
    var vcD: UIViewController!
    //var vcE: UIViewController!
    
    // Used to manually create the background fade effect when presenting a popup subview
    var fadeView: UIView!
    
    // Exploding menu elements
    var menuButton: UIButton!
    var statusButton: UIButton!
    var waterButton: UIButton!
    var foodButton: UIButton!
    var exerciseButton: UIButton!
    var weightButton: UIButton!
    
    // Tracks which tab bar item is currently selected
    var selectedItem: UITabBarItem!
    
    // Stores the height and width of the view (for formatting)
    var viewWidth: CGFloat!
    var viewHeight: CGFloat!
    
    // Tracks whether the exploding menu is currently shown or not
    var menuEnabled = false
    
    // Passed from downstream CustomAlertViewController to then pass back downstream to the DetailTableViewController
    var selection = ""
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the fadeView to be totally transparent
        fadeView = UIView(frame: self.view.frame)
        fadeView.backgroundColor = UIColor.blackColor()
        fadeView.alpha = 0.0
        
        // Add a gesture recognizer to control when the fadeView is tapped
        let singleTapBackground = UITapGestureRecognizer(target: self, action: #selector(CustomTabBarController.backgroundTapped(_:)))
        singleTapBackground.numberOfTapsRequired = 1
        fadeView.addGestureRecognizer(singleTapBackground)
        
        view.addSubview(fadeView)
        
        // Get the height and width of the view
        viewWidth = view.frame.width
        viewHeight = view.frame.height
        
        // Add the menu button (The exploding menu) to 10% bigger than the other buttons
        let menuButtonSize = tabBar.frame.height * 1.1
        
        menuButton = UIButton(frame: CGRect(x: viewWidth / 2 - menuButtonSize / 2, y: viewHeight - menuButtonSize * 1.05, width: menuButtonSize, height: menuButtonSize))
        
        menuButton.setImage(UIImage(named: "menu-button"), forState: UIControlState.Normal)
        
        // Add a gesture recognizer to the menu button
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(CustomTabBarController.menuTapped(_:)))
        singleTap.numberOfTapsRequired = 1
        menuButton.addGestureRecognizer(singleTap)
        
        // Add the buttons revealsed when the menu "explodes"
        // Give each its own gusture recognizer
        let menuItemSize = CGFloat(Int(0.9 * menuButtonSize))
        
        statusButton = UIButton(frame: CGRect(x: viewWidth / 2 - menuItemSize / 2, y: viewHeight - menuButtonSize * 1.05, width: menuItemSize, height: menuItemSize))
        statusButton.setImage(UIImage(named: "Status"), forState: UIControlState.Normal)
        
        let statusTap = UITapGestureRecognizer(target: self, action: #selector(CustomTabBarController.statusTapped(_:)))
        singleTap.numberOfTapsRequired = 1
        statusButton.addGestureRecognizer(statusTap)
        
        waterButton = UIButton(frame: CGRect(x: viewWidth / 2 - menuItemSize / 2, y: viewHeight - menuButtonSize * 1.05, width: menuItemSize, height: menuItemSize))
        waterButton.setImage(UIImage(named: "Water"), forState: UIControlState.Normal)
        
        let waterTap = UITapGestureRecognizer(target: self, action: #selector(CustomTabBarController.waterTapped(_:)))
        waterTap.numberOfTapsRequired = 1
        waterButton.addGestureRecognizer(waterTap)
        
        foodButton = UIButton(frame: CGRect(x: viewWidth / 2 - menuItemSize / 2, y: viewHeight - menuButtonSize * 1.05, width: menuItemSize, height: menuItemSize))
        foodButton.setImage(UIImage(named: "Food"), forState: UIControlState.Normal)
        
        let foodTap = UITapGestureRecognizer(target: self, action: #selector(CustomTabBarController.foodTapped(_:)))
        foodTap.numberOfTapsRequired = 1
        foodButton.addGestureRecognizer(foodTap)
        
        exerciseButton = UIButton(frame: CGRect(x: viewWidth / 2 - menuItemSize / 2, y: viewHeight - menuButtonSize * 1.05, width: menuItemSize, height: menuItemSize))
        exerciseButton.setImage(UIImage(named: "Exercise"), forState: UIControlState.Normal)
        
        let exerciseTap = UITapGestureRecognizer(target: self, action: #selector(CustomTabBarController.exerciseTapped(_:)))
        exerciseTap.numberOfTapsRequired = 1
        exerciseButton.addGestureRecognizer(exerciseTap)
        
        weightButton = UIButton(frame: CGRect(x: viewWidth / 2 - menuItemSize / 2, y: viewHeight - menuButtonSize * 1.05, width: menuItemSize, height: menuItemSize))
        weightButton.setImage(UIImage(named: "Weight"), forState: UIControlState.Normal)
        
        let weightTap = UITapGestureRecognizer(target: self, action: #selector(CustomTabBarController.weightTapped(_:)))
        weightTap.numberOfTapsRequired = 1
        weightButton.addGestureRecognizer(weightTap)
        
        // Hide the built-in tab bar
        tabBar.hidden = true
        
        // Configure the custom tab bar
        customTabBar = UITabBar(frame: CGRect(x: tabBar.frame.origin.x, y: tabBar.frame.origin.y, width: tabBar.frame.width, height: tabBar.frame.height))
        
        // Initialize each of the tab bar items
        itemA = UITabBarItem(title: "Home", image: UIImage(named: "Home-25"), selectedImage: nil)
        itemB = UITabBarItem(title: "Journal", image: UIImage(named: "Document-25"), selectedImage: nil)
        hiddenItem = UITabBarItem(title: "", image: UIImage(named: "Home-25"), selectedImage: nil)
        itemC = UITabBarItem(title: "Challenges", image: UIImage(named: "Sword-25"), selectedImage: nil)
        itemD = UITabBarItem(title: "Account", image: UIImage(named: "Account-25"), selectedImage: nil)
//        moreItem = UITabBarItem(tabBarSystemItem: .More, tag: 0)
//        itemD = UITabBarItem(title: "D", image: UIImage(named: "character-d-7"), selectedImage: nil)
//        itemE = UITabBarItem(title: "E", image: UIImage(named: "character-e-7"), selectedImage: nil)
        
        // Initiate each view controller and assign its associated tab bar item
        vcA = (storyboard?.instantiateViewControllerWithIdentifier("Home"))! as UIViewController
        vcA.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "Home-25"), selectedImage: nil)
        vcB = (storyboard?.instantiateViewControllerWithIdentifier("Journal"))! as UIViewController
        vcB.tabBarItem = UITabBarItem(title: "Journal", image: UIImage(named: "Document-25"), selectedImage: nil)
        vcHidden = (storyboard?.instantiateViewControllerWithIdentifier("Hidden"))! as
        UIViewController
        vcC = (storyboard?.instantiateViewControllerWithIdentifier("Challenges"))! as UIViewController
        vcC.tabBarItem = UITabBarItem(title: "Challenges", image: UIImage(named: "Sword-25"), selectedImage: nil)
        vcD = (storyboard?.instantiateViewControllerWithIdentifier("Account"))! as UIViewController
        vcD.tabBarItem = UITabBarItem(title: "Account", image: UIImage(named: "Account-25"), selectedImage: nil)
       // vcE = (storyboard?.instantiateViewControllerWithIdentifier("E"))! as UIViewController
       // vcE.tabBarItem = UITabBarItem(title: "E", image: UIImage(named: "character-e-7"), selectedImage: nil)
        
        // Add the tab bar items to the customTabBar
        customTabBar.items = [itemA, itemB, hiddenItem, itemC, itemD]
        
        // Add the view controllers to the tab bar controller
        viewControllers = [vcA, vcB, vcHidden, vcC, vcD]
        
        // Disable editing of the tab bar arrangement
        customizableViewControllers = []
        
        // Set the first one as selected by default
        selectedViewController = vcA
        customTabBar.selectedItem = itemA
        selectedItem = itemA
        
        // Set this class as the tab bar delegate
        customTabBar.delegate = self
        
        // Hide the fadeView for now (brought to the front when triggered by user interaction)
        view.sendSubviewToBack(fadeView)
        
        // Add the customTabBar and exploding menu elements
        view.addSubview(customTabBar)
        view.addSubview(statusButton)
        view.addSubview(waterButton)
        view.addSubview(foodButton)
        view.addSubview(exerciseButton)
        view.addSubview(weightButton)
        view.addSubview(menuButton)
    }
    
    // MARK: - Tab Bar Delegate Methods
    
    // Responds to tab bar item selection
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        // Select the view controller associated with the chosen tab bar item and update selectedItem
        // unless the hidden item is tapped, in which case do nothing
        switch(item) {
        case itemA:
            selectedViewController = vcA
            customTabBar.selectedItem = itemA
            selectedItem = itemA
            break
        case itemB:
            selectedViewController = vcB
            customTabBar.selectedItem = itemB
            selectedItem = itemB
            break
        case hiddenItem:
            customTabBar.selectedItem = selectedItem
            break
        case itemC:
            selectedViewController = vcC
            customTabBar.selectedItem = itemC
            selectedItem = itemC
            break
//        case moreItem:
//            selectedViewController = moreNavigationController
//            customTabBar.selectedItem = moreItem
//            selectedItem = moreItem
//            break
        case itemD:
            selectedViewController = vcD
            customTabBar.selectedItem = itemD
            selectedItem = itemD
            break
//        case itemE:
//            selectedViewController = vcE
//            customTabBar.selectedItem = itemE
//            selectedItem = itemE
//            break
        default:
            selectedViewController = vcA
            customTabBar.selectedItem = itemA
            break
        }
    }
    
    // MARK: - Gesture Recognizer Methods
    
    // This method is invoked when the menu is tapped
    func menuTapped(gestureRecognizer: UIGestureRecognizer) {
        
        // If the menu is closed, open it
        if(!menuEnabled) {
            
            menuEnabled = true
            openMenu()
        }
            // If the menu is open, close it
        else {
            
            menuEnabled = false
            closeMenu(true)
        }
        
    }
    
    // This method is invoked when the gray background is tapped
    func backgroundTapped(gestureRecognizer: UIGestureRecognizer) {
        
        // Close the menu
        menuEnabled = false
        closeMenu(true)
    }
    
    // This method is invoked when the status button is tapped
    func statusTapped(gestureRecognizer: UIGestureRecognizer) {
        
        // Animate fading out the other buttons and opening the custom alert view
        UIView.animateWithDuration(0.4, animations: {
            
            self.waterButton.alpha = 0.0
            self.foodButton.alpha = 0.0
            self.exerciseButton.alpha = 0.0
            self.weightButton.alpha = 0.0
            }, completion: { (value: Bool) in
                
                self.menuEnabled = false
                self.closeMenu(false)
                self.openCustomAlertView() // make this unique for a more interesting user interface
        })
    }
    
    // This method is invoked when the water button is tapped
    func waterTapped(gestureRecognizer: UIGestureRecognizer) {
        
        // Animate fading out the other buttons and opening the custom alert view
        UIView.animateWithDuration(0.4, animations: {
            
            self.statusButton.alpha = 0.0
            self.foodButton.alpha = 0.0
            self.exerciseButton.alpha = 0.0
            self.weightButton.alpha = 0.0
            }, completion: { (value: Bool) in
                
                self.menuEnabled = false
                self.closeMenu(false)
                self.openCustomAlertView() // make this unique for a more interesting user interface
        })
    }
    
    // This method is invoked when the food button is tapped
    func foodTapped(gestureRecognizer: UIGestureRecognizer) {
        
        // Animate fading out the other buttons and opening the custom alert view
        UIView.animateWithDuration(0.4, animations: {
            
            self.statusButton.alpha = 0.0
            self.waterButton.alpha = 0.0
            self.exerciseButton.alpha = 0.0
            self.weightButton.alpha = 0.0
            }, completion: { (value: Bool) in
                
                self.menuEnabled = false
                self.closeMenu(false)
                self.openCustomAlertView() // make this unique for a more interesting user interface
        })
    }
    
    // This method is invoked when the exercise button is tapped
    func exerciseTapped(gestureRecognizer: UIGestureRecognizer) {
        
        // Animate fading out the other buttons and opening the custom alert view
        UIView.animateWithDuration(0.4, animations: {
            
            self.statusButton.alpha = 0.0
            self.waterButton.alpha = 0.0
            self.foodButton.alpha = 0.0
            self.weightButton.alpha = 0.0
            }, completion: { (value: Bool) in
                
                self.menuEnabled = false
                self.closeMenu(false)
                self.openCustomAlertView() // make this unique for a more interesting user interface
        })
    }
    
    // This method is invoked when the weight button is tapped
    func weightTapped(gestureRecognizer: UIGestureRecognizer) {
        
        // Animate fading out the other buttons and opening the custom alert view
        UIView.animateWithDuration(0.4, animations: {
            
            self.statusButton.alpha = 0.0
            self.waterButton.alpha = 0.0
            self.foodButton.alpha = 0.0
            self.exerciseButton.alpha = 0.0
            }, completion: { (value: Bool) in
                
                self.menuEnabled = false
                self.closeMenu(false)
                self.openCustomAlertView() // make this unique for a more interesting user interface
        })
    }
    
    // MARK: Menu Animations
    
    // Animates opening the exploding menu
    func openMenu() {
        
        // Restore the opaqueness of all the buttons
        self.statusButton.alpha = 1.0
        self.waterButton.alpha = 1.0
        self.foodButton.alpha = 1.0
        self.exerciseButton.alpha = 1.0
        self.weightButton.alpha = 1.0
        
        // Bring the buttons and fadeView to front such that the fadeView covers everything EXCEPT the buttons
        self.view.bringSubviewToFront(self.fadeView)
        self.view.bringSubviewToFront(self.statusButton)
        self.view.bringSubviewToFront(self.waterButton)
        self.view.bringSubviewToFront(self.foodButton)
        self.view.bringSubviewToFront(self.exerciseButton)
        self.view.bringSubviewToFront(self.weightButton)
        self.view.bringSubviewToFront(self.menuButton)
        
        // Animate rotating to menu button and fading the background quickly
        UIView.animateWithDuration(0.3, animations: {
            
            self.menuButton.transform = CGAffineTransformMakeRotation((-45.0 * CGFloat(M_PI)) / 180.0)
            self.fadeView.alpha = 0.7
            }, completion: nil)
        
        // Animate springing out the individual menu buttons a little more slowly
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            
            self.statusButton.transform = CGAffineTransformMakeTranslation(-0.3 * self.viewWidth, -0.125 * self.viewHeight)
            self.waterButton.transform = CGAffineTransformMakeTranslation(-0.18 * self.viewWidth, -0.22 * self.viewHeight)
            self.foodButton.transform = CGAffineTransformMakeTranslation(0, -0.25 * self.viewHeight)
            self.exerciseButton.transform = CGAffineTransformMakeTranslation(0.18 * self.viewWidth, -0.22 * self.viewHeight)
            self.weightButton.transform = CGAffineTransformMakeTranslation(0.3 * self.viewWidth, -0.125 * self.viewHeight)
            }, completion: nil)
    }
    
    // Animates opening the exploding menu
    func closeMenu(unfadeBackground: Bool) {
        
        // Animate bring all the buttons back underneath the main menu button
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            
            // If the caller passes in true, make the fadeView completely transparent
            if unfadeBackground {
                
                self.fadeView.alpha = 0.0
            }
            
            self.menuButton.transform = CGAffineTransformMakeRotation(0.0)
            self.statusButton.transform = CGAffineTransformMakeTranslation(0, 0)
            self.waterButton.transform = CGAffineTransformMakeTranslation(0, 0)
            self.foodButton.transform = CGAffineTransformMakeTranslation(0, 0)
            self.exerciseButton.transform = CGAffineTransformMakeTranslation(0, 0)
            self.weightButton.transform = CGAffineTransformMakeTranslation(0, 0)
            
            }, completion: { (value: Bool) in
                
                // If the caller passes in true, move the fadeView to the back
                // (completely restoring the UI to how it was before opening the menu)
                if unfadeBackground {
                    
                    self.view.sendSubviewToBack(self.fadeView)
                }
        })
    }
    
    // MARK: - Custom Alert View
    
    // Instantiate and present the custom alert view (popup)
    func openCustomAlertView() {
        
        let alert = storyboard?.instantiateViewControllerWithIdentifier("alert") as! CustomAlertViewController
        alert.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        alert.sender = self
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Custom Navigation
    
    // Called downstream to handle custom alert view's selection
    func segueToDetailTableViewController() {
        
        self.performSegueWithIdentifier("alertViewRowSelected", sender: self)
    }
    
    // MARK: - Prepare for Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "alertViewRowSelected" {
            let detailController = segue.destinationViewController as! DetailTableViewController
            // Pass the selection downstream
            detailController.selection = selection
            self.fadeView.alpha = 0.0
            self.view.sendSubviewToBack(self.fadeView)
        }
        
    }
}

