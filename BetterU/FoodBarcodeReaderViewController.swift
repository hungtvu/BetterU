//
//  FoodBarcodeReaderViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/16/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit
import AVFoundation

class FoodBarcodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // Create and initialize instance variables
    var foodName: String = ""
    var foodNutritionData = [String: String]()
    
    /*
     Create an AVCaptureSession object and store its object reference into "avCaptureSession" constant.
     AVCaptureSession object is used to coordinate the flow of data from AV input devices to outputs.
     */
    let avCaptureSession = AVCaptureSession()
    
    /*
     "AVCaptureVideoPreviewLayer is a subclass of CALayer that you use to display video
     as it is being captured by an input device.
     */
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // Declare an instance variable to hold the object reference of a UIImageView object
    var scanningRegionView: UIImageView!
    
    // Declare an instance variable to hold the object reference of a UIImageView object
    var scanningCompleteView: UIImageView!
    
    // Declare and initialize view width and height
    var viewWidth: CGFloat = 0.0
    var viewHeight: CGFloat = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the scene title
        self.title = "Food Barcode Reader"
        
        // Obtain the Height and Width of the view
        viewHeight = view.frame.height
        viewWidth = view.frame.width
        
        constructScanningRegionView()
        
        constructScanningCompleteView()
        
        // Set the default AV Capture Device to capture data of media type video
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            let captureDeviceInput: AVCaptureDeviceInput? = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
            
            // AV Capture input device is initialized and ready
            avCaptureSession.addInput(captureDeviceInput)
            
        } catch let error as NSError {
            // An NSError object contains detailed error information than is possible using only an error code or error string
            
            // AV Capture input device failed to be available
            
            /*
             Create a UIAlertController object; dress it up with title, message, and preferred style;
             and store its object reference into local variable alertController
             */
            let alertController = UIAlertController(title: "AVCaptureDeviceInput Failed!",
                                                    message: "An error occurred during AV capture device input: \(error)",
                                                    preferredStyle: UIAlertControllerStyle.Alert)
            
            // Create a UIAlertAction object and add it to the alert controller
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            // Present the alert controller by calling the presentViewController method
            presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        /*
         Create an AVCaptureMetadataOutput object and store its object reference into local constant "output".
         "An AVCaptureMetadataOutput object intercepts metadata objects emitted by its associated capture
         connection and forwards them to a delegate object for processing."
         */
        let output = AVCaptureMetadataOutput()
        
        /*
         Set self to be the delegate to notify when new metadata objects become available.
         Set dispatch queue on which to execute the delegate’s methods.
         */
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        // Set the rectangle of interest to match the bounding box we drew above
        output.rectOfInterest = CGRectMake(0.45, 0.1, 0.1, 0.8)
        
        avCaptureSession.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // Add a preview so the user can see what the camera is detecting
        previewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession) as AVCaptureVideoPreviewLayer
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Move the scanningRegionView subview so that it appears on top of its siblings
        view.bringSubviewToFront(scanningRegionView)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Start the AV Capture Session running. It will run until it is stopped later.
        avCaptureSession.startRunning()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Reinitialize foodNutritionData
        foodNutritionData = [String: String]()
        
        // Move the scanningCompleteView subview so that it appears behind its siblings
        self.view.sendSubviewToBack(scanningCompleteView)
    }
    
    /*
     --------------------------------------
     MARK: - Construct Scanning Region View
     --------------------------------------
     */
    func constructScanningRegionView() {
        
        // Create an image view object to show the entire view frame as the scanning region
        scanningRegionView = UIImageView(frame: view.frame)
        
        // Create a bitmap-based graphics context as big as the scanning region and make it the Current Context
        UIGraphicsBeginImageContext(scanningRegionView.frame.size)
        
        // Draw the entire image in the specified rectangle, which is the entire view frame (scanning region)
        scanningRegionView.image?.drawInRect(CGRect(x: 0, y: 0, width: scanningRegionView.frame.width, height: scanningRegionView.frame.height))
        
        /*
         Display a left bracket "[" and right bracket "]" to designate the area of scanning.
         For an example view size of viewWidth = 414 and viewHeight = 736.
         Origin (x, y) = (0, 0) is at the left bottom corner.
         
         (41,442) ------- (62,442)               (352,442) ------- (373,442)
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         |                                              |
         (41,294) ------- (62,294)               (352,294) ------- (373,294)
         */
        
        //-------------------------------------------
        //         Draw the Left Bracket
        //-------------------------------------------
        
        // Set the line drawing starting coordinate to (62, 294)
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.15, viewHeight * 0.4)
        
        // Draw bracket bottom line from (62, 294) to (41, 294)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.1, viewHeight * 0.4)
        
        // Draw bracket left line from (41, 294) to (41, 442)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.1, viewHeight * 0.6)
        
        // Draw bracket top line from (41, 442) to (62, 442)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.15,viewHeight * 0.6)
        
        //-------------------------------------------
        //         Draw the Right Bracket
        //-------------------------------------------
        
        // Set the line drawing starting coordinate to (352,294)
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.85, viewHeight * 0.4)
        
        // Draw bracket bottom line from (352,294) to (373, 294)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.9, viewHeight * 0.4)
        
        // Draw bracket right line from (373, 294) to (373, 442)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.9, viewHeight * 0.6)
        
        // Draw bracket top line from (373, 442) to (352, 442)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.85, viewHeight * 0.6)
        
        //-------------------------------------------
        //    Set Properties of the Bracket Lines
        //-------------------------------------------
        
        // Set the bracket lines with a squared-off end
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Butt)
        
        // Set the bracket line width to 5
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5)
        
        // Set the bracket line color to light gray
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), UIColor.lightGrayColor().CGColor)
        
        // Set the bracket line blend mode to be normal
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), CGBlendMode.Normal)
        
        // Set the bracket line stroke path
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        
        // // Set the bracket line Antialiasin off
        CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), false)
        
        //-------------------------------------------
        //    Draw the Red Line as the Focus Line
        //-------------------------------------------
        
        // Set the line drawing starting coordinate to (62,368)
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.15, viewHeight * 0.5)
        
        // Draw the focus line from (62,368) to (352, 368)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.85, viewHeight * 0.5)
        
        // Set the properties of the red focus line
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Butt)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1)
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), UIColor.redColor().CGColor)
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), CGBlendMode.Normal)
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        
        // Set the image based on the contents of the current bitmap-based graphics context to be the scanningRegionView's image
        scanningRegionView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Remove the current bitmap-based graphics context from the top of the stack
        UIGraphicsEndImageContext()
        
        // Add the newly created scanningRegionView as a subview of the current view
        view.addSubview(scanningRegionView)
    }
    
    /*
     ----------------------------------------
     MARK: - Construct Scanning Complete View
     ----------------------------------------
     */
    func constructScanningCompleteView() {
        
        // Create an image view object to show the entire view frame as the scanning complete view
        scanningCompleteView = UIImageView(frame: view.frame)
        
        // Create a bitmap-based graphics context as big as the view frame size and make it the Current Context
        UIGraphicsBeginImageContext(scanningCompleteView.frame.size)
        
        // Draw the entire image in the specified rectangle, which is the entire view frame
        scanningCompleteView.image?.drawInRect(CGRect(x: 0, y: 0, width: scanningCompleteView.frame.width, height: scanningCompleteView.frame.height))
        
        //-------------------------------------------
        //         Draw the Left Bracket
        //-------------------------------------------
        
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.15, viewHeight * 0.4)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.1, viewHeight * 0.4)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.1, CGFloat(Int(viewHeight * 0.6)))
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.15, CGFloat(Int(viewHeight * 0.6)))
        
        //-------------------------------------------
        //         Draw the Right Bracket
        //-------------------------------------------
        
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.85, CGFloat(Int(viewHeight * 0.4)))
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.9, CGFloat(Int(viewHeight * 0.4)))
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.9, CGFloat(Int(viewHeight * 0.6)))
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), viewWidth * 0.85, CGFloat(Int(viewHeight * 0.6)))
        
        //-------------------------------------------
        //    Set Properties of the Bracket Lines
        //-------------------------------------------
        
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), CGLineCap.Butt)
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5)
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), UIColor.greenColor().CGColor)
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), CGBlendMode.Normal)
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), false)
        
        // Set the image based on the contents of the current bitmap-based graphics context to be the scanningCompleteView's image
        scanningCompleteView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Remove the current bitmap-based graphics context from the top of the stack
        UIGraphicsEndImageContext()
        
        // Add the newly created scanningCompleteView as a subview of the current view
        view.addSubview(scanningCompleteView)
        
        // Move the scanningCompleteView subview so that it appears behind its siblings
        view.sendSubviewToBack(scanningCompleteView)
    }
    
    /*
     --------------------------------------------------------------
     MARK: - AVCaptureMetadataOutputObjectsDelegate Protocol Method
     --------------------------------------------------------------
     */
    
    // Informs the delegate (self) that the capture output object emitted new metadata objects, i.e., a known barcode is read
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var barcodeRead = ""
        
        // Create an Array of acceptable barcode types
        let barCodeTypes = [AVMetadataObjectTypeUPCECode,
                            AVMetadataObjectTypeCode39Code,
                            AVMetadataObjectTypeCode39Mod43Code,
                            AVMetadataObjectTypeEAN13Code,
                            AVMetadataObjectTypeEAN8Code,
                            AVMetadataObjectTypeCode93Code,
                            AVMetadataObjectTypeCode128Code,
                            AVMetadataObjectTypePDF417Code,
                            AVMetadataObjectTypeQRCode,
                            AVMetadataObjectTypeAztecCode
        ]
        
        for metadata in metadataObjects {
            for barcodeType in barCodeTypes {
                if metadata.type == barcodeType {
                    
                    // Move the scanningCompleteView subview so that it appears on top of its siblings
                    self.view.bringSubviewToFront(scanningCompleteView)
                    
                    // Obtain the barcode as a String. Barcode is a number commonly displayed with the barcode.
                    barcodeRead = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    
                    // Stop the AV Capture Session running
                    self.avCaptureSession.stopRunning()
                    
                    break
                }
            }
        }
        
        // If the barcode was read, call the processBarcode function
        if barcodeRead != "" {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nutritionDataFromBarcodeViewController = storyboard.instantiateViewControllerWithIdentifier("NutritionDataFromBarcode") as! NutritionDataFromBarcodeViewController
            
            nutritionDataFromBarcodeViewController.barcode = barcodeRead
            
            self.presentViewController(nutritionDataFromBarcodeViewController, animated: true, completion: nil)
        }
    }
}
