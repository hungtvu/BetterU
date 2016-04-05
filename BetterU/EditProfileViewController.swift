//
//  EditProfileViewController.swift
//  BetterU
//
//  Created by Hung Vu on 4/4/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet var editPhotoButton: UIButton!
    @IBOutlet var emailLabel: UILabel!
    
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
    @IBOutlet var weightTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    
    
    @IBOutlet var genderSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func editPhotoButtonTapped(sender: UIButton) {
    }
   
    @IBAction func saveButtonTapped(sender: UIButton) {
    }

}
