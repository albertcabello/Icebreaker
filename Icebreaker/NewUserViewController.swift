//
//  NewUserViewController.swift
//  Testing
//
//  Created by Alberto Cabello on 10/12/16.
//  Copyright © 2016 Alberto Cabello. All rights reserved.
//
import UIKit

class NewUserViewController: UIViewController, UITextFieldDelegate {
    
    //Initialize fields so that they can be used anywhere in the class
    let emailField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 150, y: UIScreen.main.bounds.size.height/2 - 100, width: 300.0, height: 40))
    //let phoneField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 150, y: UIScreen.main.bounds.size.height/2 - 50, width: 300.0, height: 40))
    let usrField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 150, y: UIScreen.main.bounds.size.height/2 - 50, width: 300.0, height: 40))
    let passwordField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 150, y: UIScreen.main.bounds.size.height/2 , width: 300.0, height: 40))
    let confirmField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 150, y: UIScreen.main.bounds.size.height/2 + 50, width: 300.0, height: 40))
    
    
    //Initialize the button so it can be called anywhere in any of the functions
    let createButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 75, y: UIScreen.main.bounds.size.height/2 + 100, width: 150, height: 40))
    
    override func viewDidLoad() {
        print("Create new user screen loaded")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Creates label that identifies this view from others.  Will be removed in the final version
        let identifierLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 300, height: 40))
        identifierLabel.text = "New User View Controller"
        self.view.addSubview(identifierLabel)
        
        
        //Create the text field for email, username, desired password, confirm password, and phone number
        
        //Email input field
        emailField.borderStyle = .roundedRect
        emailField.placeholder = "you@yourdomain.com"
        emailField.keyboardType = .emailAddress
        emailField.delegate = self
        
        //Username input field
        usrField.borderStyle = .roundedRect
        usrField.placeholder = "Username"
        usrField.delegate = self
        
        //Password input field
        passwordField.borderStyle = .roundedRect
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
        
        //Password confirmation field
        confirmField.borderStyle = .roundedRect
        confirmField.placeholder = "Confirm password"
        confirmField.isSecureTextEntry = true
        confirmField.delegate = self
        confirmField.returnKeyType = .go
        
        //        //Phone input field
        //        phoneField.placeholder = "(###)###+###"
        //        phoneField.borderStyle = .roundedRect
        //        phoneField.keyboardType = .phonePad
        //        phoneField.returnKeyType = .done
        //        phoneField.delegate = self
        //This will be added back in when I figure out how to have an enter key on the keypad
        
        //Add each text field to the view
        self.view.addSubview(emailField)
        self.view.addSubview(usrField)
        self.view.addSubview(passwordField)
        self.view.addSubview(confirmField)
        //self.view.addSubview(phoneField)
        
        //Create button that accepts the new user information and sends them to the map view
        createButton.backgroundColor = UIColor.green
        createButton.setTitle("Let's see who's near us!", for: .normal)
        createButton.addTarget(self, action: #selector(NewUserViewController.toMap), for: .touchUpInside)
        createButton.layer.cornerRadius = 5
        createButton.layer.borderColor = UIColor.black.cgColor
        createButton.titleLabel?.numberOfLines = 1
        createButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //Add the button to the view
        self.view.addSubview(createButton)
        
    }
    
    //Takes a floating point number for the y coordinate of the top left corner of the box, desired box width, and desired box height
    //Returns a CGRect where the center of the CGRect is aligned on the x axis
    func frameGenerator(y: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        let screenWidth = UIScreen.main.bounds.size.width
        return CGRect(x: screenWidth/2 - width/2, y: y, width: width, height: height)
        
    }
    
    //Takes the user from this view controller to the map view controller
    func toMap(sender: UIButton!) {
        self.present(MapViewController(), animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.emailField:
            self.usrField.becomeFirstResponder()
        case self.usrField:
            self.passwordField.becomeFirstResponder()
        case self.passwordField:
            self.confirmField.becomeFirstResponder()
        default:
            self.toMap(sender: createButton)
        }
        return true
    }
}
