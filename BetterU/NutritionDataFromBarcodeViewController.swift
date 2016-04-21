//
//  NutritionDataFromBarcodeViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/17/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class NutritionDataFromBarcodeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate {

    /* Initializing object references to the objects on top of the view */
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var customNavigationItem: UINavigationItem!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var servingSizeTextField: UITextField!
    @IBOutlet var numberOfServingsTextField: UITextField!
    @IBOutlet var nutritionDataTable: UITableView!
    
    // Initializing nutritional facts. These values are passed down from the LogCaloriesViewController class
    var totalFatWithUnit = ""
    var saturatedFatWithUnit = ""
    var monounsaturatedFatWithUnit = ""
    var polyunsaturatedFatWithUnit = ""
    var cholesterolWithUnit = ""
    var sodiumWithUnit = ""
    var sugarWithUnit = ""
    var carbsWithUnit = ""
    var fiberWithUnit = ""
    var proteinWithUnit = ""
    
    // Percentage based on a 2,000 calorie diet
    var dailyVitA = ""
    var dailyVitC = ""
    var dailyCalcium = ""
    var dailyIron = ""
    
    
    // Variable to store the serving size unit (ie, fl oz.)
    var servingSizeUnit = ""
    
    // Variable to store the serving size qty (ie. 8)
    var servingSizeQty = ""
    
    // Variable to combine the unit and quantity (ie. 8.0 fl oz)
    var servingSizeWithQty = ""
    
    // The actual quantity of serving, (ie., 1 serving of 8 fl oz drink)
    var quantityOfServingSize = 1
    
    var calories = ""
    
    /* These API keys are generated from the nutritionIX API. We will need to use that API in order to get nutritional data from barcodes. */
//    var appID = "53b1fdec"
//    var apiKey = "6b5bad5a01843e74a28b2570ce697e84"
    var appID = "5762d638"
    var apiKey = "3b1bc72f9763713d5890af352c9dca56"
    
    // Create and initialize instance variables
    var foodName: String = ""
    
    // Keys (Items) of the foodNutritionData dictionary
    var nutritionTitleArray = [String]()
    
    // Values of the dictionary
    var nutrientValueArray = [String]()
    
    var barcode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adds a tap gesture to the scroll view to allow the keyboard's dismissal when tapping on the background
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NutritionDataFromBarcodeViewController.hideKeyboard(_:)))
        
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        
        scrollView.addGestureRecognizer(tapGesture)
        
        registerForKeyboardNotifications()
        
        self.numberOfServingsTextField.text! = String(quantityOfServingSize)
        processBarcode(barcode)
        
        self.customNavigationItem.title = foodName
        self.servingSizeTextField.text! = servingSizeWithQty
        
        
        // Nutritional title and data
        nutritionTitleArray.append("Calories")
        nutritionTitleArray.append("Fat")
        nutritionTitleArray.append("Saturated Fat")
        nutritionTitleArray.append("Polyunsaturated Fat")
        nutritionTitleArray.append("Monounsaturated Fat")
        nutritionTitleArray.append("Cholesterol")
        nutritionTitleArray.append("Sodium")
        nutritionTitleArray.append("Sugar")
        nutritionTitleArray.append("Carbohydrate")
        nutritionTitleArray.append("Fiber")
        nutritionTitleArray.append("Protein")
        nutritionTitleArray.append("Daily Vitamin A")
        nutritionTitleArray.append("Daily Vitamin C")
        nutritionTitleArray.append("Daily Calcium")
        nutritionTitleArray.append("Daily Iron")
        
        self.nutrientValueArray.append(self.calories)
        self.nutrientValueArray.append(self.totalFatWithUnit)
        self.nutrientValueArray.append(self.saturatedFatWithUnit)
        self.nutrientValueArray.append(self.polyunsaturatedFatWithUnit)
        self.nutrientValueArray.append(self.monounsaturatedFatWithUnit)
        self.nutrientValueArray.append(self.cholesterolWithUnit)
        self.nutrientValueArray.append(self.sodiumWithUnit)
        self.nutrientValueArray.append(self.sugarWithUnit)
        self.nutrientValueArray.append(self.carbsWithUnit)
        self.nutrientValueArray.append(self.fiberWithUnit)
        self.nutrientValueArray.append(self.proteinWithUnit)
        self.nutrientValueArray.append(self.dailyVitA)
        self.nutrientValueArray.append(self.dailyVitC)
        self.nutrientValueArray.append(self.dailyCalcium)
        self.nutrientValueArray.append(self.dailyIron)
        
        /* Changes the status bar color to the navigation bar's color */
        let statusBar = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0))
        statusBar.backgroundColor = UIColor(red: 65/255, green: 192/255, blue: 247/255, alpha: 1)
        self.view.addSubview(statusBar)
        
    }

    // Updates the nutritional table once the textfield has resigned to first responder
    func textFieldDidEndEditing(textField: UITextField)
    {
        updateNutrients()
    }
    
    @IBAction func backButtonTapped(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
     --------------------------
     MARK: - Barcode Processing
     --------------------------
     */
    func processBarcode(barcode: String) {
        
        // A "barcode" corresponds to a number, which is commonly displayed as part of the barcode.
        
        // Declare local variables
        var foodDataForBarcode: NSData
        
        // Compose the search query containing the barcode, appID, and appKey
        let nutritionixURL = "https://api.nutritionix.com/v1_1/item?upc=\(barcode)&appId=\(appID)&appKey=\(apiKey)"
        
        // Store the search query result into foodDataReturned
        let foodDataReturned: NSData? = NSData(contentsOfURL: NSURL(string: nutritionixURL)!)
        
        if let foodDataObtained = foodDataReturned {
            
            foodDataForBarcode = foodDataObtained
            
        } else {
            self.showErrorMessage("No results found for the barcode scanned.")
            
            return
        }
        
        /*
         NSJSONSerialization class is used to convert JSON and Foundation objects (e.g., NSDictionary) into each other.
         NSJSONSerialization class's method JSONObjectWithData returns an NSDictionary object from the given JSON data.
         */
        let jsonDict: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(foodDataForBarcode, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        
        /*
         Print the JSON data returned to see its structure. To do this:
         - Connect your iOS device to your computer (iMac, MacBook).
         - Deploy your app to run on your device.
         - While connected to Xcode, run the app on your device, and scan a food barcode.
         - The JSON data will be displayed in Xcode's Debug area.
         
         Example JSON data returned as a Dictionary with Key = Value. Note that {...} represents a Dictionary.
         
         {
         "allergen_contains_eggs" = "<null>";
         "allergen_contains_fish" = "<null>";
         "allergen_contains_gluten" = "<null>";
         "allergen_contains_milk" = "<null>";
         "allergen_contains_peanuts" = "<null>";
         "allergen_contains_shellfish" = "<null>";
         "allergen_contains_soybeans" = "<null>";
         "allergen_contains_tree_nuts" = "<null>";
         "allergen_contains_wheat" = "<null>";
         "brand_id" = 51db37ba176fe9790a898c99;
         "brand_name" = "Nonni's";
         "item_description" = "<null>";
         "item_id" = 548f0c48e684eb8d120e719c;
         "item_name" = "Chocolate Hazelnut Biscotti";
         "leg_loc_id" = "<null>";
         "nf_calcium_dv" = 2;
         "nf_calories" = 160;
         "nf_calories_from_fat" = 60;
         "nf_cholesterol" = 35;
         "nf_dietary_fiber" = 1;
         "nf_ingredient_statement" = "<null>";
         "nf_iron_dv" = 4;
         "nf_monounsaturated_fat" = "<null>";
         "nf_polyunsaturated_fat" = "<null>";
         "nf_protein" = 3;
         "nf_refuse_pct" = "<null>";
         "nf_saturated_fat" = 3;
         "nf_serving_size_qty" = 1;
         "nf_serving_size_unit" = biscotti;
         "nf_serving_weight_grams" = 35;
         "nf_servings_per_container" = 1;
         "nf_sodium" = 110;
         "nf_sugars" = 13;
         "nf_total_carbohydrate" = 24;
         "nf_total_fat" = 6;
         "nf_trans_fatty_acid" = 0;
         "nf_vitamin_a_dv" = 2;
         "nf_vitamin_c_dv" = 0;
         "nf_water_grams" = "<null>";
         "old_api_id" = "<null>";
         "updated_at" = "2014-12-15T16:58:26.000Z";
         "usda_fields" = "<null>";
         }
         
         */
        
        if let servingSizeUnit = jsonDict["nf_serving_size_unit"] as? String
        {
            self.servingSizeUnit = servingSizeUnit
        }
        
        if let servingSizeQty = jsonDict["nf_serving_size_qty"] as? Double
        {
            self.servingSizeQty = String(servingSizeQty)
        }
        
        if let name = jsonDict["item_name"] as? String {
            self.foodName = name
        }
        
        if let totalFat = jsonDict["nf_total_fat"] as? Float {
            self.totalFatWithUnit = String(Double(Double(totalFat) * Double(numberOfServingsTextField.text!)!)) + " g"
        }
        else
        {
            self.totalFatWithUnit = ""
        }
        
        if let saturatedFat = jsonDict["nf_saturated_fat"] as? Float {
            self.saturatedFatWithUnit = String(Double(saturatedFat) * Double(numberOfServingsTextField.text!)!) + " g"
        }
        
        if let monounsaturatedFat = jsonDict["nf_monounsaturated_fat"] as? Float {
            self.monounsaturatedFatWithUnit = String(Double(monounsaturatedFat) * Double(numberOfServingsTextField.text!)!) + " g"
        }
        
        if let polyunsaturatedFat = jsonDict["nf_polyunsaturated_fat"] as? Float {
            self.polyunsaturatedFatWithUnit = String(Double(polyunsaturatedFat) * Double(numberOfServingsTextField.text!)! ) + " g"
        }
        
        if let cholesterol = jsonDict["nf_cholesterol"] as? Int {
            self.cholesterolWithUnit = String(Double(cholesterol) * Double(numberOfServingsTextField.text!)!) + " mg"
        }
        
        if let sodium = jsonDict["nf_sodium"] as? Int {
            self.sodiumWithUnit = String(Double(sodium) * Double(numberOfServingsTextField.text!)!) + " mg"
        }
        
        if let sugar = jsonDict["nf_sugars"] as? Int {
            self.sugarWithUnit = String(Double(sugar) * Double(numberOfServingsTextField.text!)! ) + " g"
        }
        
        if let carbohydrate = jsonDict["nf_total_carbohydrate"] as? Int {
            self.carbsWithUnit = String(Double(Double(carbohydrate) * Double(numberOfServingsTextField.text!)!)) + " g"
        }
        else
        {
            self.carbsWithUnit = ""
        }
        
        if let fiber = jsonDict["nf_dietary_fiber"] as? Int {
            self.fiberWithUnit = String(Double(fiber) * Double(numberOfServingsTextField.text!)!) + " g"
        }
        
        if let protein = jsonDict["nf_protein"] as? Int {
            self.proteinWithUnit = String(Double(Double(protein) * Double(numberOfServingsTextField.text!)!)) + " g"
        }
        else
        {
            self.proteinWithUnit = ""
        }
        
        if let vitaminA = jsonDict["nf_vitamin_a_dv"] as? Int {
            self.dailyVitA = String(vitaminA) + "%"
        }
        
        if let vitaminC = jsonDict["nf_vitamin_c_dv"] as? Int {
            self.dailyVitC = String(vitaminC) + "%"
        }
        
        if let calcium = jsonDict["nf_calcium_dv"] as? Int {
            self.dailyCalcium = String(calcium) + "%"
        }
        
        if let iron = jsonDict["nf_iron_dv"] as? Int {
            self.dailyIron = String(iron) + "%"
        }
        
        self.servingSizeWithQty = servingSizeQty + " " + servingSizeUnit
        
        if proteinWithUnit == ""
        {
            proteinWithUnit = "0.0"
        }
        
        if totalFatWithUnit == ""
        {
            totalFatWithUnit = "0.0"
        }
        
        if carbsWithUnit == ""
        {
            carbsWithUnit = "0.0"
        }
        
        // Calculates the calories
        calories = setRecipeCalories(Double(proteinWithUnit.stringByReplacingOccurrencesOfString(" g", withString: ""))!, fatValue: Double(totalFatWithUnit.stringByReplacingOccurrencesOfString(" g", withString: ""))!, carbsValue: Double(carbsWithUnit.stringByReplacingOccurrencesOfString(" g", withString: ""))!)
    }
    
    //--------------------
    // Set Recipe Calories
    //--------------------
    
    // This function calculates the total calories per serving in a formula
    func setRecipeCalories(proteinValue: Double, fatValue: Double, carbsValue: Double) -> String
    {
        // Calculate the calories per serving from those 3 values
        var caloriesPerServing = 0.0
        
        caloriesPerServing = ((fatValue) * 9) + ((carbsValue) * 4) + ((proteinValue) * 4)
        
        return String(Int(caloriesPerServing))
        
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
            let alertController = UIAlertController(title: "Not a valid food item!", message: errorMessage,
                                                    preferredStyle: UIAlertControllerStyle.Alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    //----------------------------------------
    // Return Number of Sections in Table View
    //----------------------------------------
    
    // Each table view section corresponds to a country
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    //---------------------------------
    // Return Number of Rows in Section
    //---------------------------------
    
    // Number of rows in a given country (section) = Number of Cities in the given country (section)
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return nutritionTitleArray.count
    }
    
    //-----------------------------
    // Set Title for Section Header
    //-----------------------------
    
    // Set the table view section header
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Nutritional Facts"
    }
    
    //-----------------------------
    // Set Title for Section Footer
    //-----------------------------
    
    // Set the table view section footer with its own custom label
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerLabel = UILabel()
        
        footerLabel.frame = CGRectZero
        footerLabel.font = UIFont.systemFontOfSize(12)
        footerLabel.text = "% - Daily Values are based on a 2,000 calorie diet. Daily Values are only shown from the default serving size."
        footerLabel.numberOfLines = 2
        footerLabel.textAlignment = NSTextAlignment.Center
        footerLabel.textColor = UIColor.grayColor()
        
        
        return footerLabel;
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    //-------------------------------------
    // Prepare and Return a Table View Cell
    //-------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let row: Int = indexPath.row
        
        let cell = nutritionDataTable.dequeueReusableCellWithIdentifier("nutritionFacts")! as UITableViewCell
        
        cell.textLabel!.text = nutritionTitleArray[row]
        
        if nutrientValueArray[row] == ""
        {
            cell.detailTextLabel!.text = "No data"
        }
            
        else
        {
            cell.detailTextLabel!.text = nutrientValueArray[row]
        }
        
        return cell
    }

    /* Updates the necessary nutrients by removing all of the values from the array that was used and repopulating it with new ones */
    func updateNutrients()
    {
        dispatch_async(dispatch_get_main_queue(),
        {
            self.nutrientValueArray.removeAll(keepCapacity: false)
            
            self.processBarcode(self.barcode)
            
            self.nutrientValueArray.append(self.calories)
            self.nutrientValueArray.append(self.totalFatWithUnit)
            self.nutrientValueArray.append(self.saturatedFatWithUnit)
            self.nutrientValueArray.append(self.polyunsaturatedFatWithUnit)
            self.nutrientValueArray.append(self.monounsaturatedFatWithUnit)
            self.nutrientValueArray.append(self.cholesterolWithUnit)
            self.nutrientValueArray.append(self.sodiumWithUnit)
            self.nutrientValueArray.append(self.sugarWithUnit)
            self.nutrientValueArray.append(self.carbsWithUnit)
            self.nutrientValueArray.append(self.fiberWithUnit)
            self.nutrientValueArray.append(self.proteinWithUnit)
            self.nutrientValueArray.append(self.dailyVitA)
            self.nutrientValueArray.append(self.dailyVitC)
            self.nutrientValueArray.append(self.dailyCalcium)
            self.nutrientValueArray.append(self.dailyIron)
            
            self.nutritionDataTable.reloadData()
        })
    }
    
    // Allows the keyboard to hide by the user's interaction (background touch)
    func hideKeyboard(sender: UIScrollView)
    {
        scrollView.endEditing(true)
    }
    
    /*
     ---------------------------------------
     MARK: - Handling Keyboard Notifications
     ---------------------------------------
     */
    
    // This method is called in viewDidLoad() to register self for keyboard notifications
    func registerForKeyboardNotifications() {
        
        // "An NSNotificationCenter object (or simply, notification center) provides a
        // mechanism for broadcasting information within a program." [Apple]
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self,
            selector:   #selector(NutritionDataFromBarcodeViewController.keyboardWillShow(_:)),    // <-- Call this method upon Keyboard Will SHOW Notification
            name:       UIKeyboardWillShowNotification,
            object:     nil)
        
        notificationCenter.addObserver(self,
            selector:   #selector(NutritionDataFromBarcodeViewController.keyboardWillHide(_:)),    //  <-- Call this method upon Keyboard Will HIDE Notification
            name:       UIKeyboardWillHideNotification,
            object:     nil)
    }
    
    // This method is called upon Keyboard Will SHOW Notification
    func keyboardWillShow(sender: NSNotification) {
        
        // "userInfo, the user information dictionary stores any additional
        // objects that objects receiving the notification might use." [Apple]
        let info: NSDictionary = sender.userInfo!
        
        /*
         Key     = UIKeyboardFrameBeginUserInfoKey
         Value   = an NSValue object containing a CGRect that identifies the start frame of the keyboard in screen coordinates.
         */
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        
        // Obtain the size of the keyboard
        let keyboardSize: CGSize = value.CGRectValue().size
        
        // Create Edge Insets for the view.
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        
        // Set the distance that the content view is inset from the enclosing scroll view.
        scrollView.contentInset = contentInsets
        
        // Set the distance the scroll indicators are inset from the edge of the scroll view.
        scrollView.scrollIndicatorInsets = contentInsets
        
        //-----------------------------------------------------------------------------------
        // If active text field is hidden by keyboard, scroll the content up so it is visible
        //-----------------------------------------------------------------------------------
        
        // Obtain the frame size of the View
        var selfViewFrameSize: CGRect = self.view.frame
        
        // Subtract the keyboard height from the self's view height
        // and set it as the new height of the self's view
        selfViewFrameSize.size.height -= keyboardSize.height
        
        // Obtain the size of the active UITextField object
        let numberOfServingSizeRect: CGRect? = numberOfServingsTextField!.frame
        
        // Obtain the active UITextField object's origin (x, y) coordinate
        let numberOfServingSizeOrigin: CGPoint? = numberOfServingSizeRect?.origin
        
        
        if (!CGRectContainsPoint(selfViewFrameSize, numberOfServingSizeOrigin!)) {
            
            // If active UITextField object's origin is not contained within self's View Frame,
            // then scroll the content up so that the active UITextField object is visible
            scrollView.scrollRectToVisible(numberOfServingSizeRect!, animated:true)
        }
        
    }
    
    // This method is called upon Keyboard Will HIDE Notification
    func keyboardWillHide(sender: NSNotification) {
        
        // Set contentInsets to top=0, left=0, bottom=0, and right=0
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        
        // Set scrollView's contentInsets to top=0, left=0, bottom=0, and right=0
        scrollView.contentInset = contentInsets
        
        // Set scrollView's scrollIndicatorInsets to top=0, left=0, bottom=0, and right=0
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // This method is called when the user taps Return on the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Deactivate the text field and remove the keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    /*
     ---------------------------------------------
     MARK: - Register and Unregister Notifications
     ---------------------------------------------
     */
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

}
