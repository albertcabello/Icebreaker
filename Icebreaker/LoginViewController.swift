//
//  LoginViewController.swift
//  Testing
//
//  Created by Alberto Cabello on 10/11/16.
//  Copyright © 2016 Alberto Cabello. All rights reserved.
//
import UIKit
import Alamofire


class LoginViewController: UIViewController, UITextFieldDelegate {
    var networkController:NetworkController!
    
    //Initialize all the fields so that they can be referenced by all functions
    let usrField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 300.0/2, y: UIScreen.main.bounds.size.height/2 - 30, width: 300.0, height: 30))
    let passwordField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 300.0/2 , y: UIScreen.main.bounds.size.height/2 + 10, width: 300.0, height: 30))
    
    
    //Initialize the login button so that a function outside viewDidAppear(_anitmated:) can call it
    let loginButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - (125/2), y: UIScreen.main.bounds.size.height/2 + 50, width: 125, height: 30))
    
    
    override func viewDidLoad() {
        //Set what the view does when it loads
        self.view.backgroundColor = UIColor.white
        super.viewDidLoad()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //let label = UILabel(frame: CGRect(x: 20, y: 20, width: 300, height: 40))
        //label.text = "Login View Controller"
        
        
//        let placeholderLogo = UILabel(frame: CGRect(x: 20, y: 90, width: 125, height: 40))
//        placeholderLogo.center.x = self.view.center.x
//        print("placeholderLogo created")
//        placeholderLogo.text = "Logo goes here"
        
        let logo = UIImage(named: "Logo.png")
        let logoView = UIImageView(image: logo)
        logoView.frame = CGRect(x: 20, y: 90, width: 125, height: 200)
        logoView.contentMode = .scaleAspectFit
        logoView.image = logo
        logoView.center.x = self.view.center.x
        
        
        
        
        
        
        
        //Username and password text field intializers
        //Sets the delegate, the style, and placeholder
        usrField.delegate = self
        usrField.borderStyle = .roundedRect
        usrField.placeholder = "Username"
        usrField.returnKeyType = .next
        usrField.layer.borderWidth = 1
        usrField.layer.cornerRadius = 5
        //usrField.backgroundColor = UIColor.gray
        
        
        passwordField.borderStyle = .roundedRect
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
        passwordField.returnKeyType = .go
        passwordField.layer.borderWidth = 1
        passwordField.layer.cornerRadius = 5
        //passwordField.backgroundColor = UIColor.gray
        
        
        //Initialize the login button to the view
        //Sets the title, color, rounded corners, and the action when pressed
        loginButton.setTitle("Login!", for: .normal)
        loginButton.addTarget(self, action: #selector(LoginViewController.login), for: .touchUpInside)
        loginButton.backgroundColor = UIColor.white
        loginButton.setTitleColor(UIColor.black, for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        //loginButton.layer.borderColor = UIColor.black.cgColor
        
        
        //Add a create new user button to the view
        let newUserButton = UIButton(frame: CGRect(x: self.view.frame.width/2 - (125/2), y: self.view.frame.height/2 + 90, width: 125, height: 30))
        newUserButton.setTitle("Create an account", for: .normal)
        newUserButton.setTitleColor(UIColor.black, for: .normal)
        newUserButton.addTarget(self, action: #selector(LoginViewController.newUser), for: .touchUpInside)
        newUserButton.setTitleColor(UIColor.black, for: .normal)
        newUserButton.titleLabel?.numberOfLines = 1
        newUserButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        
        //Add everything to the view
        //self.view.addSubview(label)
        self.view.addSubview(usrField)
        self.view.addSubview(passwordField)
        //self.view.addSubview(placeholderLogo)
        self.view.addSubview(loginButton)
        self.view.addSubview(newUserButton)
        self.view.addSubview(logoView)
    }
    
    
    //Action for when the login button is clicked
    func login(sender: UIButton!) {
        
        //Verify that the username and password fields are not blank
        guard usrField.hasText && passwordField.hasText else { //Check that both username and password are entered
            
            //The message that alert will show
            
            //The OK button for alert
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            if !usrField.hasText && !passwordField.hasText { //User has not entered the username or password
                //I can buy this one, maybe they wanted to test it
                
                let message = "Your username and password are blank! Please enter them in, if you don't have a username or password, create a new user!"
                let alert = UIAlertController(title: "Enter username and password!", message: message, preferredStyle: .alert)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if usrField.hasText && !passwordField.hasText { //User has entered the username but not the password
                //I can also buy this one, I'll admit I've done this one before by accident
                let message = "You didn't enter a password! Please enter it to continue"
                let alert = UIAlertController(title: "Enter username and password!", message: message, preferredStyle: .alert)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            if !usrField.hasText && passwordField.hasText { //User has not entered the username but has entered the password
                //Now this one, I can't buy this one.  Why would this even happen?
                let message = "Your username is blank! Please enter it to continue."
                let alert = UIAlertController(title: "Enter username and password!", message: message, preferredStyle: .alert)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            return
        }
        
        //Username user provided
        let userGiven = usrField.text
        
        //Password user provided
        let passGiven = passwordField.text
        
        
        networkController.setUsername(user: userGiven!)
        networkController.setPassword(pass: passGiven!)
        networkController.login() { success in
            if success {
                let mvc = MapViewController()
                mvc.networkController = self.networkController
                self.present(mvc, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Uh-oh!", message: "The username or password is wrong!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        

    }
    
    
    //Acion for when the create new user button is clicked
    func newUser(sender: UIButton!) {
        let nuvc:NewUserViewController = NewUserViewController()
        nuvc.networkController = self.networkController
        nuvc.view.backgroundColor = UIColor.white
        self.present(nuvc, animated: true, completion: nil)
    }
    
    
    //Function that determines what to do when enter is hit on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.usrField:
            self.passwordField.becomeFirstResponder()
        default:
            self.login(sender: loginButton)
        }
        return true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        //Remove resources when there is a memory warning
        super.didReceiveMemoryWarning()
    }
    
    
    
}
