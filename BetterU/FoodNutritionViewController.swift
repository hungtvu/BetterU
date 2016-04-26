//
//  FoodNutritionViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/15/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class FoodNutritionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet var servingSizeTextField: UITextField!
    @IBOutlet var numberOfServingsTextField: UITextField!
    @IBOutlet var nutritionDataTable: UITableView!
    @IBOutlet var customNavigationItem: UINavigationItem!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var scrollView: UIScrollView!
    
    // These are API Keys from the USDA API. Free keys are available on their website.
    let usdaApiKey = "4niv8KdOlh2eILltqqldVhCoNsw62qKN6NiRPSo4"
    let usdaApiKey2 = "kpXNL7bTB0hPpWVSWNnPePhsHg0OnTforAKvJ7NE"
    let usdaApiKey3 = "6qer4AubBAx23pY4cizKwaDznfmCNyEJ3uxZlnEJ"
    
    // Initializing nutritional facts. These values are passed down from the LogCaloriesViewController class
    var totalFatWithUnit = ""
    var saturatedFatWithUnit = ""
    var monounsaturatedFatWithUnit = ""
    var polyunsaturatedFatWithUnit = ""
    var cholesterolWithUnit = ""
    var sodiumWithUnit = ""
    var potassiumWithUnit = ""
    var carbsWithUnit = ""
    var fiberWithUnit = ""
    var proteinWithUnit = ""
    var vitaminAWithUnit = ""
    var vitaminCWithUnit = ""
    var calciumWithUnit = ""
    var ironWithUnit = ""
    
    // Percentage based on a 2,000 calorie diet
    var dailyVitA = ""
    var dailyVitC = ""
    var dailyCalcium = ""
    var dailyIron = ""
    
    var foodName = ""
    var servingSize = ""
    var calories = ""
    var ndbno = ""
    
    var nutritionTitleArray = [String]()
    var nutrientValueArray = [String]()
    var servingSizeArray = [String]()
    
    var servingQuantity = ""
    var quantityOfServingSize = 1
    
    // Initialize picker view for the serving size options
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Changes the status bar color to the navigation bar's color */
        let statusBar = UIView(frame:
            CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 20.0))
        statusBar.backgroundColor = UIColor(red: 41/255, green: 128/255, blue: 186/255, alpha: 1)
        self.view.addSubview(statusBar)
        
        self.customNavigationItem.title = foodName
        
        registerForKeyboardNotifications()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FoodNutritionViewController.hideKeyboard(_:)))
        
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        
        scrollView.addGestureRecognizer(tapGesture)
        
        // Nutritional title and data
        nutritionTitleArray.append("Calories")
        nutritionTitleArray.append("Fat")
        nutritionTitleArray.append("Saturated Fat")
        nutritionTitleArray.append("Polyunsaturated Fat")
        nutritionTitleArray.append("Monounsaturated Fat")
        nutritionTitleArray.append("Cholesterol")
        nutritionTitleArray.append("Sodium")
        nutritionTitleArray.append("Potassium")
        nutritionTitleArray.append("Carbohydrate")
        nutritionTitleArray.append("Fiber")
        nutritionTitleArray.append("Protein")
        nutritionTitleArray.append("Daily Vitamin A")
        nutritionTitleArray.append("Daily Vitamin C")
        nutritionTitleArray.append("Daily Calcium")
        nutritionTitleArray.append("Daily Iron")
        
        numberOfServingsTextField.text! = String(quantityOfServingSize)
        
        prelimJSONParseForServingSize(ndbno)
        servingSizeTextField.text! = servingSizeArray[0]
        
        parseBasicNutritionDataFromNdbno(ndbno)
       
        
        self.nutrientValueArray.append(self.calories)
        self.nutrientValueArray.append(self.totalFatWithUnit + " g")
        self.nutrientValueArray.append(self.saturatedFatWithUnit + " g")
        self.nutrientValueArray.append(self.polyunsaturatedFatWithUnit + " g")
        self.nutrientValueArray.append(self.monounsaturatedFatWithUnit + " g")
        self.nutrientValueArray.append(self.cholesterolWithUnit + " mg")
        self.nutrientValueArray.append(self.sodiumWithUnit + " mg")
        self.nutrientValueArray.append(self.potassiumWithUnit + " mg")
        self.nutrientValueArray.append(self.carbsWithUnit + " g")
        self.nutrientValueArray.append(self.fiberWithUnit + " g")
        self.nutrientValueArray.append(self.proteinWithUnit + " g")
        self.nutrientValueArray.append(self.dailyVitA + "%")
        self.nutrientValueArray.append(self.dailyVitC + "%")
        self.nutrientValueArray.append(self.dailyCalcium + "%")
        self.nutrientValueArray.append(self.dailyIron + "%")
        
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Adds a toolbar on top of the picker view so that the user can cancel their selection
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 65/255, green: 192/255, blue: 247/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adds the button within the toolbar with an action
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AgeGenderViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AgeGenderViewController.cancelPicker(_:)))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        // Adds the pickerview to the textfield
        servingSizeTextField.inputView = pickerView
        
        // Adds the toolbar to the textfield on top of the pickerview
        servingSizeTextField.inputAccessoryView = toolBar
        
        
        // Create a custom button with the checkmark image
        let btnName = UIButton()
        btnName.setImage(UIImage(named: "checkmark4"), forState: .Normal)
        btnName.frame = CGRectMake(0, 0, 15, 15)
        btnName.addTarget(self, action: #selector(FoodNutritionViewController.addCalories(_:)), forControlEvents: .TouchUpInside)
        
        // Set Right/Left Bar Button item
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.customNavigationItem.rightBarButtonItem = rightBarButton
        
        //print(ndbno)
    }
    
    // When the checkmark button is tapped, the user will be able to update their caloric intake
    func addCalories(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Updates the nutritional table once the textfield has resigned to first responder
    func textFieldDidEndEditing(textField: UITextField)
    {
        updateNutrients()
    }
    
    /* Updates the necessary nutrients by removing all of the values from the array that was used and repopulating it with new ones */
    func updateNutrients()
    {
        dispatch_async(dispatch_get_main_queue(),
        {
            self.nutrientValueArray.removeAll(keepCapacity: false)
            
            self.parseBasicNutritionDataFromNdbno(self.ndbno)
            
            self.nutrientValueArray.append(self.calories)
            self.nutrientValueArray.append(self.totalFatWithUnit + " g")
            self.nutrientValueArray.append(self.saturatedFatWithUnit + " g")
            self.nutrientValueArray.append(self.polyunsaturatedFatWithUnit + " g")
            self.nutrientValueArray.append(self.monounsaturatedFatWithUnit + " g")
            self.nutrientValueArray.append(self.cholesterolWithUnit + " mg")
            self.nutrientValueArray.append(self.sodiumWithUnit + " mg")
            self.nutrientValueArray.append(self.potassiumWithUnit + " mg")
            self.nutrientValueArray.append(self.carbsWithUnit + " g")
            self.nutrientValueArray.append(self.fiberWithUnit + " g")
            self.nutrientValueArray.append(self.proteinWithUnit + " g")
            self.nutrientValueArray.append(self.dailyVitA + "%")
            self.nutrientValueArray.append(self.dailyVitC + "%")
            self.nutrientValueArray.append(self.dailyCalcium + "%")
            self.nutrientValueArray.append(self.dailyIron + "%")
            
            self.nutritionDataTable.reloadData()
        })
    }
    
    // Allows the keyboard to hide by the user's interaction (background touch)
    func hideKeyboard(sender: UIScrollView)
    {
        scrollView.endEditing(true)
    }

    
    /*
     --------------------------------------------------
     MARK: - Toolbar actions with the press of a button
     --------------------------------------------------
     */
    func donePicker(sender: UIPickerView)
    {
        servingSizeTextField.resignFirstResponder()
    }
    
    func cancelPicker(sender: UIPickerView)
    {
        servingSizeTextField!.text = servingSize
        servingSizeTextField.resignFirstResponder()
    }
    
    /*
     ----------------------------------------------
     MARK: - PickerView Delegate/Datasource methods
     ----------------------------------------------
     */
    
    // Setting the number of components in the pickerview
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Set the number of rows in the picker view
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return servingSizeArray.count
    }
    
    // Set title for each row
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return servingSizeArray[row]
    }
    
    // Updates the textfield when the picker view is selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        servingSizeTextField.text = servingSizeArray[row]
        updateNutrients()
    }
    
    func prelimJSONParseForServingSize(ndbno: String)
    {
        let usdaApiUrlForFoodStats = "http://api.nal.usda.gov/ndb/reports/?ndbno=\(ndbno)&type=b&format=json&api_key=\(self.usdaApiKey2)"
        
        // Convert URL to NSURL
        let url = NSURL(string: usdaApiUrlForFoodStats)
        
        var jsonData: NSData?
        
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch _ as NSError
        {
            self.showErrorMessage("Your search has no results. Please try again!")
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
                
                let jsonDataDictionary = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                /*
                 "report": {
                 "sr": "28",
                 "type": "Basic",
                 "food": {
                 "ndbno": "18240",
                 "name": "Croissants, apple",
                 "nutrients": [
                 {
                 "nutrient_id": "255",
                 "name": "Water",
                 "group": "Proximates",
                 "unit": "g",
                 "value": "45.60",
                 "measures": [
                 {
                 "label": "oz",
                 "eqv": 28.35,
                 "qty": 1.0,
                 "value": "12.93"
                 },
                 {
                 "label": "croissant, medium",
                 "eqv": 57.0,
                 "qty": 1.0,
                 "value": "25.99"
                */
                
                // Grabs the report from the API
                let reportFromDictionary = jsonDataDictionary!["report"] as! NSDictionary
                
                // Grabs the food report, this is filled with the food name, nutrient measurements, etc.
                let foodFromDictionary = reportFromDictionary["food"] as! NSDictionary
                
                // Grabs the actual nutrients, Fat, Protein, etc. as an array
                let nutrientsArrayFromDictionary = foodFromDictionary["nutrients"] as! NSArray
                
                // Initializes the NSDictionary and NSArrays for grabbing data from each previous dictionaries and arrays
                
                /* nutrientsDictFromArray is the dictionary of nutrients that is grabbed from the nutrients array. This is required to have because each dictionary is within an array. */
                var nutrientsDictFromArray = NSDictionary()
                
                /* The measuresArrayFromNutrientDict is an NSArray that stores in information about the serving sizes and its value associated with each nutrient */
                var measuresArrayFromNutrientDict = NSArray()
                
                /* The nutrientDictFromMeasureArray is a dictionary that holds the specific information about each serving size associated with each nutrient's value. This dictionary is needed because it is within the measuresArrayFromNutrientDict */
                var nutrientDictFromMeasuresArray = NSDictionary()
                
                // Initialize variables that will store in each specific piece of information about each nutrient
                var servingSizeFromNutrient = ""
                var quantityOfServing = 0.0
                
                var i = 0
                while (i < nutrientsArrayFromDictionary.count)
                {
                    nutrientsDictFromArray = nutrientsArrayFromDictionary[i] as! NSDictionary
                    measuresArrayFromNutrientDict = nutrientsDictFromArray["measures"] as! NSArray
                    
                    var j = 0
                    while (j < measuresArrayFromNutrientDict.count)
                    {
                        
                        nutrientDictFromMeasuresArray = measuresArrayFromNutrientDict[j] as! NSDictionary
                        quantityOfServing = nutrientDictFromMeasuresArray["qty"] as! Double
                        quantityOfServingSize = Int(quantityOfServing)
                        servingSizeFromNutrient = nutrientDictFromMeasuresArray["label"] as! String
                        
                        servingQuantity = "\((quantityOfServing)) \(servingSizeFromNutrient)"
                        
                        if servingSizeArray.count < measuresArrayFromNutrientDict.count
                        {
                            servingSizeArray.append(servingQuantity)
                        }
                        
                        j = j + 1
                    }
                    
                   i = i + 1
                    
                }
                
                
            }catch let error as NSError
            {
                self.showErrorMessage("Error in retrieving JSON data: \(error.localizedDescription)")
                return
            }
            
        }
            
        else
        {
            self.showErrorMessage("Error in retrieving JSON data!")
        }
        
        

    }


    @IBAction func backButtonTapped(sender: UIBarButtonItem)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func parseBasicNutritionDataFromNdbno(ndbno: String)
    {
        let usdaApiUrlForFoodStats = "http://api.nal.usda.gov/ndb/reports/?ndbno=\(ndbno)&type=b&format=json&api_key=\(self.usdaApiKey2)"
        
        // Convert URL to NSURL
        let url = NSURL(string: usdaApiUrlForFoodStats)
        
        var jsonData: NSData?
        
        do {
            /*
             Try getting the JSON data from the URL and map it into virtual memory, if possible and safe.
             DataReadingMappedIfSafe indicates that the file should be mapped into virtual memory, if possible and safe.
             */
            jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch _ as NSError
        {
            self.showErrorMessage("Your search has no results. Please try again!")
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
                
                let jsonDataDictionary = try NSJSONSerialization.JSONObjectWithData(jsonDataFromApiURL, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                /*
                 "report": {
                 "sr": "28",
                 "type": "Basic",
                 "food": {
                 "ndbno": "18240",
                 "name": "Croissants, apple",
                 "nutrients": [
                 {
                 "nutrient_id": "255",
                 "name": "Water",
                 "group": "Proximates",
                 "unit": "g",
                 "value": "45.60",
                 "measures": [
                 {
                 "label": "oz",
                 "eqv": 28.35,
                 "qty": 1.0,
                 "value": "12.93"
                 },
                 {
                 "label": "croissant, medium",
                 "eqv": 57.0,
                 "qty": 1.0,
                 "value": "25.99"
                 }
                 ]
                 },
                 {
                 "nutrient_id": "208",
                 "name": "Energy",
                 "group": "Proximates",
                 "unit": "kcal",
                 "value": "254",
                 "measures": [
                 {
                 "label": "oz",
                 "eqv": 28.35,
                 "qty": 1.0,
                 "value": "72"
                 },
                 {
                 "label": "croissant, medium",
                 "eqv": 57.0,
                 "qty": 1.0,
                 "value": "145"
                 }
                 ]
                 },
                */
                
                // Grabs the report from the API
                let reportFromDictionary = jsonDataDictionary!["report"] as! NSDictionary
                
                // Grabs the food report, this is filled with the food name, nutrient measurements, etc.
                let foodFromDictionary = reportFromDictionary["food"] as! NSDictionary
                
                // Grabs the actual nutrients, Fat, Protein, etc. as an array
                let nutrientsArrayFromDictionary = foodFromDictionary["nutrients"] as! NSArray
                
                // Initializes the NSDictionary and NSArrays for grabbing data from each previous dictionaries and arrays
                
                /* nutrientsDictFromArray is the dictionary of nutrients that is grabbed from the nutrients array. This is required to have because each dictionary is within an array. */
                var nutrientsDictFromArray = NSDictionary()
                
                /* The measuresArrayFromNutrientDict is an NSArray that stores in information about the serving sizes and its value associated with each nutrient */
                var measuresArrayFromNutrientDict = NSArray()
                
                /* The nutrientDictFromMeasureArray is a dictionary that holds the specific information about each serving size associated with each nutrient's value. This dictionary is needed because it is within the measuresArrayFromNutrientDict */
                var nutrientDictFromMeasuresArray = NSDictionary()
                
                // Initialize variables that will store in each specific piece of information about each nutrient
                var nutrientName = ""
                var servingSizeFromNutrient = ""
                var quantityOfServing = 0.0
                
                var i = 0
                while (i < nutrientsArrayFromDictionary.count)
                {
                    nutrientsDictFromArray = nutrientsArrayFromDictionary[i] as! NSDictionary
                    measuresArrayFromNutrientDict = nutrientsDictFromArray["measures"] as! NSArray
                    
                    nutrientName = nutrientsDictFromArray["name"] as! String
                    
                    var j = 0
                    while (j < measuresArrayFromNutrientDict.count) {
                        
                        nutrientDictFromMeasuresArray = measuresArrayFromNutrientDict[j] as! NSDictionary
                        quantityOfServing = nutrientDictFromMeasuresArray["qty"] as! Double
                        quantityOfServingSize = Int(quantityOfServing)
                        servingSizeFromNutrient = nutrientDictFromMeasuresArray["label"] as! String
                        
                        servingQuantity = "\((quantityOfServing)) \(servingSizeFromNutrient)"
                        
                        if servingQuantity == servingSizeTextField.text!
                        {
                            // Grabs the total fat
                            if nutrientName == "Total lipid (fat)"
                            {
                                totalFatWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                            }
                            
                            // Grabs the total saturated fat
                            if nutrientName == "Fatty acids, total saturated"
                            {
                                saturatedFatWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                            }
                            
                            // Grabs the total monounsaturatedFatWithUnit
                            if nutrientName == "Fatty acids, total monounsaturated"
                            {
                                monounsaturatedFatWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                            }
                            
                            // Grabs the total polyunsaturatedFatWithUnit
                            if nutrientName == "Fatty acids, total polyunsaturated"
                            {
                                polyunsaturatedFatWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                            }
                            
                            // Grabs the total cholesterol
                            if nutrientName == "Cholesterol"
                            {
                                cholesterolWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                            }
                            
                            // Grabs the total sodium
                            if nutrientName == "Sodium, Na"
                            {
                                sodiumWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                            }
                            
                            // Grabs the total potassium
                            if nutrientName == "Potassium, K"
                            {
                                potassiumWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                            }
                            
                            // Grabs the total carbohydrate
                            if nutrientName == "Carbohydrate, by difference"
                            {
                                carbsWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                            }
                            
                            // Grabs the total fiber
                            if nutrientName == "Fiber, total dietary"
                            {
                                fiberWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                            }
                            
                            // Grabs the total protein value
                            if nutrientName == "Protein"
                            {
                                proteinWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                            }
                            
                            // Grabs the total vitamin A value
                            if nutrientName == "Vitamin A, IU"
                            {
                                vitaminAWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                                let vitaminADailyPercentage = (Double(vitaminAWithUnit)!/5000) * 100
                                dailyVitA = String(Int(vitaminADailyPercentage))
                            }
                            
                            // Grabs the total vitamin C value
                            if nutrientName == "Vitamin C, total ascorbic acid"
                            {
                                vitaminCWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                                let vitaminCDailyPercentage = (Double(vitaminCWithUnit)!/60) * 100
                                dailyVitC = String(Int(vitaminCDailyPercentage))
                            
                            }
                            
                            // Grabs the total calcium value
                            if nutrientName == "Calcium, Ca"
                            {
                                calciumWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                                let calciumDailyPercentage = (Double(calciumWithUnit)!/1000) * 100
                                dailyCalcium = String(Int(calciumDailyPercentage))
                            }
                            
                            // Grabs the total iron value
                            if nutrientName == "Iron, Fe"
                            {
                                ironWithUnit = String(Double(nutrientDictFromMeasuresArray["value"] as! String)! * Double(numberOfServingsTextField.text!)!)
                                let ironDailyPercentage = (Double(ironWithUnit)!/18) * 100
                                dailyIron = String(Int(ironDailyPercentage))
                            }
                            
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
                            calories = setRecipeCalories(Double(proteinWithUnit)!, fatValue: Double(totalFatWithUnit)!, carbsValue: Double(carbsWithUnit)!)
                            
                        }
                        
                        j = j + 1
                    }
                    
                    i = i + 1
                }
                
            }catch let error as NSError
            {
                self.showErrorMessage("Error in retrieving JSON data: \(error.localizedDescription)")
                return
            }
            
        }
            
        else
        {
            self.showErrorMessage("Error in retrieving JSON data!")
        }
        
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
            selector:   #selector(FoodNutritionViewController.keyboardWillShow(_:)),    // <-- Call this method upon Keyboard Will SHOW Notification
            name:       UIKeyboardWillShowNotification,
            object:     nil)
        
        notificationCenter.addObserver(self,
            selector:   #selector(FoodNutritionViewController.keyboardWillHide(_:)),    //  <-- Call this method upon Keyboard Will HIDE Notification
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        footerLabel.text = "% - Daily Values are based on a 2,000 calorie diet. Your daily values can change depending on your caloric needs."
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
        let cell = tableView.dequeueReusableCellWithIdentifier("nutritionFacts")! as UITableViewCell
        
        let row = indexPath.row
        
        cell.textLabel!.text = nutritionTitleArray[row]
        
        if nutrientValueArray[row] == ""
        {
            cell.detailTextLabel!.text = "No data"
        }
        else
        {
            cell.detailTextLabel!.text = nutrientValueArray[row]
        }
        
        cell.setNeedsLayout()
        
        return cell
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
