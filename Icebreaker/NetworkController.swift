//
//  UserController.swift
//  Icebreaker
//
//  Created by Alberto Cabello on 3/10/17.
//  Copyright © 2017 Alberto Cabello. All rights reserved.
//


import Foundation
import Alamofire
import SwiftyJSON

class NetworkController {
    var passGiven:String
    var userGiven:String
    var email:String
    var action:String
    
    init() {
        passGiven = ""
        userGiven = ""
        email = ""
        action = ""
    }
    

    
    func login(completion: @escaping (_ success: Bool) -> ()) {
        //Use Alamofire to verify the username and password
        let action = "login"
        let url = "http://albertocabello.com/Icebreaker-API/?action=\(action)&userGiven=\(userGiven)&passGiven=\(passGiven)"
        Alamofire.request(url).responseString { response in
            if response.result.value == "1" {
                print("Good login")
                completion(true)
            }
            else {
                print("Bad login")
                completion(false)
            }
        }
    }
    
    func register(completion: @escaping (_ response: String) -> ()){
        action = "create"
        let url = "http://albertocabello.com/Icebreaker-API/?action=\(action)&userGiven=\(userGiven)&passGiven=\(passGiven)"
        Alamofire.request(url).responseString { response in
            if response.result.value == "Username exists" {
                print("Username exists")
                completion("Username exists")
            }
            else if response.result.value == "User added" {
                print("User added")
                completion("User added")
            }
            else {
                print("Registration failed")
                completion("Registration failed")
            }
        }
    }
    
    
    func getNearbyUsers(completion: @escaping (_ users2: [User]) -> ()) {
        var users = [User]()
        action = "get"
        let url = "http://albertocabello.com/Icebreaker-API/?action=\(action)&userGiven=\(userGiven)&passGiven=\(passGiven)"
        Alamofire.request(url).responseJSON() { response in
            let json = JSON(response.result.value!)
            //Loop through API JSON response
            for (_, subJson):(String, JSON) in json {
                //Get longitude and latitude and create the annotation
                let latitude = Double(subJson["latitude"].stringValue)!
                let longitude = Double(subJson["longitude"].stringValue)!
                let name = subJson["username"].stringValue
                let user = User(name: name, desc: "" , lat: latitude, long: longitude)
                users.append(user)
    
            }
            completion(users)
        }
    }
    
    func setUsername(user:String) {
        self.userGiven = user
    }
    
    func setPassword(pass:String) {
        self.passGiven = pass
    }
    
    func setEmail(email:String) {
        self.email = email
    }
    
}
