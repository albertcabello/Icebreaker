//
//  UserAnnotation.swift
//  Icebreaker
//
//  Created by Alberto Cabello on 6/18/17.
//  Copyright © 2017 Alberto Cabello. All rights reserved.
//

import Foundation
import MapKit

class UserAnnotation: User, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    dynamic var title: String?
    
    override init(name:String, desc:String = "", lat:Double, long:Double) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.title = name
        super.init(name: name, desc: desc, lat: lat, long: long)
    }
    
    convenience init(user:User) {
        self.init(name: user.getName(), lat: user.getCoordinates().0, long: user.getCoordinates().1)
    }
    
    
}
