//
//  ExerciseImageViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/20/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class ExerciseImageViewController: UIViewController {

    @IBOutlet var step1Label: UILabel!
    @IBOutlet var step2Label: UILabel!
    
    @IBOutlet var step1ImageView: UIImageView!
    @IBOutlet var step2ImageView: UIImageView!
    
    var image1String = ""
    var image2String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

        setExerciseImage(image1String, imageViews: step1ImageView)
        setExerciseImage(image2String, imageViews: step2ImageView)
        
    }
    
    //-------------------
    // Set Exercise Image
    //-------------------
    
    func setExerciseImage(imageURL: String, imageViews: UIImageView)
    {
        if imageURL == ""
        {
            self.step1Label.alpha = 0
            imageViews.alpha = 0
            self.step2Label.alpha = 0
            
            // Create a label that tells the user that there are no images
            let label = UILabel(frame: CGRectMake(0, 0, 400, 100))
            label.numberOfLines = 0
            label.center = CGPointMake(185, 170)
            label.textAlignment = NSTextAlignment.Center
            label.text = "Sorry, no images\nwere found for this exercise."
            self.view.addSubview(label)
        }
        else
        {
            // Create an NSURL from the given URL
            let url = NSURL(string: imageURL)
            
            var imageData: NSData?
            
            do {
                /*
                 Try getting the thumbnail image data from the URL and map it into virtual memory, if possible and safe.
                 DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
                 */
                imageData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            } catch let error as NSError
            {
                self.showErrorMessage("Error in retrieving thumbnail image data: \(error.localizedDescription)")
            }
            
            if let image = imageData
            {
                // Image was successfully gotten
                imageViews.image = UIImage(data: image)
            }
            else
            {
                self.showErrorMessage("Error occurred while retrieving recipe image data!")
            }
        }
    }
    
    
    /*
     ------------------------------------------------
     MARK: - Show Alert View Displaying Error Message
     ------------------------------------------------
     */
    func showErrorMessage(errorMessage: String) {
        dispatch_async(dispatch_get_main_queue())
        { () -> Void in
            /*
             Create a UIAlertController object; dress it up with title, message, and preferred style;
             and store its object reference into local constant alertController
             */
            let alertController = UIAlertController(title: "Unable to Obtain Data!", message: errorMessage,
                                                    preferredStyle: UIAlertControllerStyle.Alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

}
