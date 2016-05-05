//
//  ChangeWeightFromCustomTabViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/23/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangeWeightFromCustomTabViewController: UIViewController {

    @IBOutlet var submitButton: UIButton!
    @IBOutlet var weightLabel: UILabel!
    
    private var cellItems = [String]()
    
    var weightToPass = 0
    
    var lastContentOffset: CGFloat = CGFloat()
    
    // Obtain object reference to the AppDelegate so that we may use the MyIngredients plist
    let applicationDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Initialize variables that are needed to update
    var weight = 0

    // Initialize variables that are NOT needed to update from textfields. These, however, are required
    // to post back the accurate data that was unchanged to the backend database
    var activityGoal = ""
    var gender = ""
    var email = ""
    var firstName = ""
    var lastName = ""
    var age = 0
    var height = 0
    var currentActivityLevel = 0
    var exp = 0
    var goalWeight = 0
    var id = 0
    var password = ""
    var username = ""
    var securityQuestion = 0
    var securityAnswer = ""
    var recipeIdBreakfast = ""
    var recipeIdDinner = ""
    var recipeIdSnacks = ""
    var recipeIdLunch = ""
    var bmr = 0
    var targetCalories = 0
    var goalType = 0
    var points = 0
    var photo = ""
    
    var isScrollingRight = false
    var scrolledOnce = false
    
    @IBOutlet weak var infiniteCollectionView: InfiniteCollectionView!
    {
        didSet
        {
            infiniteCollectionView.backgroundColor = UIColor.whiteColor()
            infiniteCollectionView.registerNib(UINib(nibName: "InfiniteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cellCollectionView")
            infiniteCollectionView.infiniteDataSource = self
            infiniteCollectionView.infiniteDelegate = self
            infiniteCollectionView.reloadData()
        }
    }
    
    func parseJson()
    {
        // Instantiate an API URL to return the JSON data
        let restApiUrl = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user/\(id)"
        
        // Convert URL to NSURL
        let url = NSURL(string: restApiUrl)
        
        var jsonData: NSData?
        
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error as NSError
        {
            print("Error in retrieving JSON data: \(error.localizedDescription)")
            return
        }
        
        if let jsonDataFromApiURL = jsonData
        {
            // The JSON data is successfully obtained from the API
            
            /*
             NSJSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
             NSJSONSerialization class's method JSONObjectWithData returns an NSDictionary object from the given JSON data.
             */
            
            do
            {
                // Grabs all of the JSON data info as an array. NOTE, this stores ALL of the info, it does NOT have
                // any info from inside of the JSON.
                let jsonDataDictInfo = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                bmr = jsonDataDictInfo["bmr"] as! Int
                recipeIdBreakfast = (jsonDataDictInfo["breakfast"] as? String)!
                recipeIdDinner = (jsonDataDictInfo["dinner"] as? String)!
                recipeIdSnacks = (jsonDataDictInfo["snack"] as? String)!
                recipeIdLunch = (jsonDataDictInfo["lunch"] as? String)!
                points = jsonDataDictInfo["points"] as! Int
                targetCalories = jsonDataDictInfo["targetCalories"] as! Int
                goalType = jsonDataDictInfo["goalType"] as! Int
                photo = jsonDataDictInfo["photo"] as! String
                
            }catch let error as NSError
            {
                print("Error in retrieving JSON data: \(error.localizedDescription)")
                return
            }
        }
            
        else
        {
            print("Error in retrieving JSON data!")
        }
        
    }

    @IBAction func submitButtonTapped(sender: UIButton)
    {
        //endpoint to database you want to post to
        let postsEndpoint: String = "http://jupiter.cs.vt.edu/BetterUAPI/webresources/com.betteru.entitypackage.user/\(id)"
        
        //This is the JSON that is being submitted. Many placeholders currently here. Feel free to replace.
        //Format is = "Field": value
        let newPost = ["DCSkipped": 0, "WCSkipped": 0, "activityGoal": activityGoal, "activityLevel": currentActivityLevel, "age": age, "bmr": bmr, "dailyChallengeIndex": 0, "email": email, "firstName": firstName, "gender": gender, "goalType": goalType, "goalWeight": goalWeight, "height": height, "id": id, "lastName": lastName, "password": password, "points": points, "securityAnswer": securityAnswer, "securityQuestion": securityQuestion, "targetCalories": targetCalories, "units": "I", "username": username, "weeklyChallengeIndex": 0, "weight": weightToPass, "lunch": recipeIdLunch, "breakfast": recipeIdBreakfast, "snack": recipeIdSnacks, "dinner": recipeIdDinner, "photo": photo]
        
        //Creating the request to post the newPost JSON var.
        Alamofire.request(.PUT, postsEndpoint, parameters: newPost as? [String : AnyObject], encoding: .JSON)
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /posts/1")
                    print(response.result.error!)
                    return
                }
                
                if let value: AnyObject = response.result.value {
                    // handle the results as JSON, without a bunch of nested if loops
                    // this might not return anything here, but check the DB just in case. It might post anyway
                    let post = JSON(value)
                    print("The post is: " + post.description)
                }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    
    @IBAction func exitButtonTapped(sender: UIButton)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        submitButton.layer.cornerRadius = 8
        
        var i = 0
        while (i <= 999)
        {
            cellItems.append(String(i))
            i = i + 1
        }
        
        // Grabbing variables from the plist
        email = applicationDelegate.userAccountInfo["Email"] as! String
        firstName = applicationDelegate.userAccountInfo["First Name"] as! String
        lastName = applicationDelegate.userAccountInfo["Last Name"] as! String
        age = applicationDelegate.userAccountInfo["Age"] as! Int
        height = applicationDelegate.userAccountInfo["Height"] as! Int
        weight = applicationDelegate.userAccountInfo["User Weight"] as! Int
        gender = applicationDelegate.userAccountInfo["Gender"] as! String
        
        activityGoal = applicationDelegate.userAccountInfo["Activity Goal"] as! String
        currentActivityLevel = applicationDelegate.userAccountInfo["Current Activity Level"] as! Int
        exp = applicationDelegate.userAccountInfo["Exp"] as! Int
        goalWeight = applicationDelegate.userAccountInfo["Goal Weight"] as! Int
        id = applicationDelegate.userAccountInfo["id"] as! Int
        password = applicationDelegate.userAccountInfo["Password"] as! String
        username = applicationDelegate.userAccountInfo["Username"] as! String
        securityQuestion = applicationDelegate.userAccountInfo["Security Question"] as! Int
        securityAnswer = applicationDelegate.userAccountInfo["Security Answer"] as! String
        
        parseJson()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
}

extension ChangeWeightFromCustomTabViewController: InfiniteCollectionViewDataSource
{
    func numberOfItems(collectionView: UICollectionView) -> Int
    {
        return cellItems.count
    }
    
    func cellForItemAtIndexPath(collectionView: UICollectionView, dequeueIndexPath: NSIndexPath, usableIndexPath: NSIndexPath)  -> UICollectionViewCell
    {
        let cell = infiniteCollectionView.dequeueReusableCellWithReuseIdentifier("cellCollectionView", forIndexPath: dequeueIndexPath) as! InfiniteCollectionViewCell
        
       
        cell.lbTitle.text = cellItems[usableIndexPath.row]
        
        // Whether the direction is right or left, calibrate the weightLabel to be more accurate.
        if isScrollingRight
        {
            weightLabel.text = String(Int(cell.lbTitle.text!)! - 3)
        }
        else
        {
            weightLabel.text = String(Int(cell.lbTitle.text!)! + 3)
        }
        
        weightToPass = Int(weightLabel.text!)!
        
        cell.backgroundImage.image = UIImage(named: "Ruler1Image")
        return cell
    }
    
    // Tells us the scrolling direction of the collection view
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        // Scrolls right
        if (lastContentOffset < scrollView.contentOffset.x)
        {
            isScrollingRight = true
        }
            
            // Scrolls left
        else if (lastContentOffset > scrollView.contentOffset.x)
        {
            isScrollingRight = false
        }
        
        lastContentOffset = scrollView.contentOffset.x
    }
}

extension ChangeWeightFromCustomTabViewController: InfiniteCollectionViewDelegate
{
    func didSelectCellAtIndexPath(collectionView: UICollectionView, usableIndexPath: NSIndexPath)
    {
        print("Selected cell with name \(cellItems[usableIndexPath.row]) at index: \(usableIndexPath.row)")
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if !scrolledOnce
        {
            weight = applicationDelegate.userAccountInfo["User Weight"] as! Int
            self.infiniteCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: cellItems.indexOf(String(weight))!, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            scrolledOnce = true
        }
    }
}



