//
//  AppDelegate.swift
//  BetterU
//
//  Created by Hung Vu on 3/31/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var userAccountInfo: NSMutableDictionary = NSMutableDictionary()
    var recipesDict: NSMutableDictionary = NSMutableDictionary()
    var savedRecipesDict: NSMutableDictionary = NSMutableDictionary()
    var savedLoggedExercisesDict: NSMutableDictionary = NSMutableDictionary()
    var savedRecommendedExercisesDict: NSMutableDictionary = NSMutableDictionary()
    var savedChallengesDict: NSMutableDictionary = NSMutableDictionary()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        /*
         All application-specific and user data must be written to files that reside in the iOS device's
         Documents directory. Nothing can be written into application's main bundle (project folder) because
         it is locked for writing after your app is published.
         
         The contents of the iOS device's Documents directory are backed up by iTunes during backup of an iOS device.
         Therefore, the user can recover the data written by your app from an earlier device backup.
         
         The Documents directory path on an iOS device is different from the one used for iOS Simulator.
         
         To obtain the Documents directory path, you use the NSSearchPathForDirectoriesInDomains function.
         However, this function was created originally for Mac OS X, where multiple such directories could exist.
         Therefore, it returns an array of paths rather than a single path.
         
         For iOS, the resulting array's first element (index=0) contains the path to the Documents directory.
         */
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        
        // Add the plist filename to the documents directory path to obtain an absolute path to the plist filename
        let plistFilePathInDocumentDirectory = documentDirectoryPath + "/UserAccountInfo.plist"
        
        let dictFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInDocumentDirectory)
        
        if let dictFromFileInDocumentDirectory = dictFromFile
        {
            // useraccountinfo plist exists
            userAccountInfo = dictFromFileInDocumentDirectory
        }
        else
        {
            // MyIngredients.plist does not exist in the directory
            // Obtain the path to the plist file
            let plistFilePathInMainBundle = NSBundle.mainBundle().pathForResource("UserAccountInfo", ofType: "plist")
            
            let dictionaryFromFileInMainBundle: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInMainBundle!)
            
            userAccountInfo = dictionaryFromFileInMainBundle!
        }
        
        // Add the plist filename to the documents directory path to obtain an absolute path to the plist filename
        let recipesPlistFilePathInDocumentDirectory = documentDirectoryPath + "/Recipes.plist"
        
        let recipesDictFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: recipesPlistFilePathInDocumentDirectory)
        
        if let dictFromFileInDocumentDirectory = recipesDictFromFile
        {
            // recipes plist exists
            recipesDict = dictFromFileInDocumentDirectory
        }
        else
        {
            // does not exist in the directory
            // Obtain the path to the plist file
            let plistFilePathInMainBundle = NSBundle.mainBundle().pathForResource("Recipes", ofType: "plist")
            
            let dictionaryFromFileInMainBundle: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInMainBundle!)
            
            recipesDict = dictionaryFromFileInMainBundle!
        }
        
        // Add the plist filename to the documents directory path to obtain an absolute path to the plist filename
        let savedRecipesPlistFilePathInDocumentDirectory = documentDirectoryPath + "/SavedRecipes.plist"
        
        let savedRecipesDictFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: savedRecipesPlistFilePathInDocumentDirectory)
        
        if let dictFromFileInDocumentDirectory = savedRecipesDictFromFile
        {
            // recipes plist exists
            savedRecipesDict = dictFromFileInDocumentDirectory
        }
        else
        {
            // does not exist in the directory
            // Obtain the path to the plist file
            let plistFilePathInMainBundle = NSBundle.mainBundle().pathForResource("SavedRecipes", ofType: "plist")
            
            let dictionaryFromFileInMainBundle: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInMainBundle!)
            
            savedRecipesDict = dictionaryFromFileInMainBundle!
        }
        
        // Add the plist filename to the documents directory path to obtain an absolute path to the plist filename
        let savedLoggedExercisesPlistFilePathInDocumentDirectory = documentDirectoryPath + "/SavedLoggedExercises.plist"
        
        let savedLoggedExercisesDictFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: savedLoggedExercisesPlistFilePathInDocumentDirectory)
        
        if let dictFromFileInDocumentDirectory = savedLoggedExercisesDictFromFile
        {
            // exercise plist exists
            savedLoggedExercisesDict = dictFromFileInDocumentDirectory
        }
        else
        {
            // does not exist in the directory
            // Obtain the path to the plist file
            let plistFilePathInMainBundle = NSBundle.mainBundle().pathForResource("SavedLoggedExercises", ofType: "plist")
            
            let dictionaryFromFileInMainBundle: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInMainBundle!)
            
            savedLoggedExercisesDict = dictionaryFromFileInMainBundle!
        }
        
        // Add the plist filename to the documents directory path to obtain an absolute path to the plist filename
        let savedRecommendedExercisesPlistFilePathInDocumentDirectory = documentDirectoryPath + "/SavedRecommendedExercises.plist"
        
        let savedRecommendedExercisesDictFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: savedRecommendedExercisesPlistFilePathInDocumentDirectory)
        
        if let dictFromFileInDocumentDirectory = savedRecommendedExercisesDictFromFile
        {
            // exercise plist exists
            savedRecommendedExercisesDict = dictFromFileInDocumentDirectory
        }
        else
        {
            // does not exist in the directory
            // Obtain the path to the plist file
            let plistFilePathInMainBundle = NSBundle.mainBundle().pathForResource("SavedRecommendedExercises", ofType: "plist")
            
            let dictionaryFromFileInMainBundle: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInMainBundle!)
            
            savedRecommendedExercisesDict = dictionaryFromFileInMainBundle!
        }
        
        // Add the plist filename to the documents directory path to obtain an absolute path to the plist filename
        let savedChallengesPlistFilePathInDocumentDirectory = documentDirectoryPath + "/Challenges.plist"
        
        let savedChallengesPlistFromFile: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: savedChallengesPlistFilePathInDocumentDirectory)
        
        if let dictFromFileInDocumentDirectory = savedChallengesPlistFromFile
        {
            // exercise plist exists
            savedChallengesDict = dictFromFileInDocumentDirectory
        }
        else
        {
            // does not exist in the directory
            // Obtain the path to the plist file
            let plistFilePathInMainBundle = NSBundle.mainBundle().pathForResource("Challenges", ofType: "plist")
            
            let dictionaryFromFileInMainBundle: NSMutableDictionary? = NSMutableDictionary(contentsOfFile: plistFilePathInMainBundle!)
            
            savedChallengesDict = dictionaryFromFileInMainBundle!
        }
        
        return true
    }
    
    func resetAppToFirstView()
    {
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignInView") as! SignInViewController
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        /*
         "UIApplicationWillResignActiveNotification is posted when the app is no longer active and loses focus.
         An app is active when it is receiving events. An active app can be said to have focus.
         It gains focus after being launched, loses focus when an overlay window pops up or when the device is
         locked, and gains focus when the device is unlocked." [Apple]
         */
        
        // Define the file path to the MyFavoriteMovies.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectoryPath = paths[0] as String
        
        // Add plist file name to the documents directory path
        let plistFileFromDocumentDirectory = documentDirectoryPath + "/UserAccountInfo.plist"
        
        // Write NSMutableDictionary to the destination file
        userAccountInfo.writeToFile(plistFileFromDocumentDirectory, atomically: true)
        
        // Add plist file name to the documents directory path
        let recipesPlistFileFromDocumentDirectory = documentDirectoryPath + "/Recipes.plist"
        
        // Write NSMutableDictionary to the destination file
        recipesDict.writeToFile(recipesPlistFileFromDocumentDirectory, atomically: true)
        
        // Add plist file name to the documents directory path
        let savedRecipesPlistFileFromDocumentDirectory = documentDirectoryPath + "/SavedRecipes.plist"
        
        // Write NSMutableDictionary to the destination file
        savedRecipesDict.writeToFile(savedRecipesPlistFileFromDocumentDirectory, atomically: true)
        
        // Add plist file name to the documents directory path
        let savedLoggedExercisesPlistFileFromDocumentDirectory = documentDirectoryPath + "/SavedLoggedExercises.plist"
        
        // Write NSMutableDictionary to the destination file
        savedLoggedExercisesDict.writeToFile(savedLoggedExercisesPlistFileFromDocumentDirectory, atomically: true)
        
        // Add plist file name to the documents directory path
        let savedRecommendedExercisesPlistFileFromDocumentDirectory = documentDirectoryPath + "/SavedRecommendedExercises.plist"
        
        // Write NSMutableDictionary to the destination file
        savedRecommendedExercisesDict.writeToFile(savedRecommendedExercisesPlistFileFromDocumentDirectory, atomically: true)
        
        // Add plist file name to the documents directory path
        let savedChalengesPlistFileFromDocumentDirectory = documentDirectoryPath + "/Challenges.plist"
        
        // Write NSMutableDictionary to the destination file
        savedChallengesDict.writeToFile(savedChalengesPlistFileFromDocumentDirectory, atomically: true)
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

