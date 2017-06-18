//
//  User.swift
//  Icebreaker
//
//  Created by Alberto Cabello on 3/10/17.
//  Copyright © 2017 Alberto Cabello. All rights reserved.
//

import Foundation

class User: NSObject {
    private var name:String
    private var desc:String
    private var lat:Double
    private var long:Double
    
    override var hashValue: Int {
        return name.hashValue
    }
    
    init(name:String, desc:String = "", lat:Double, long:Double) {
        self.name = name
        self.desc = desc
        self.lat = lat
        self.long = long

    }
    
    func setName(name names:String) {
        self.name = names
    }
    
    func setDesc(description desc:String) {
        self.desc = desc
    }
    
    func getName() -> String {
        return name
    }
    
    func getDescription() -> String {
        return desc
    }
    
    func getCoordinates() -> (Double, Double) {
        return (lat, long)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return ((lhs.getName() == rhs.getName()) && (lhs.getCoordinates() == rhs.getCoordinates()))
    }
    
}
