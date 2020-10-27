//
//  Place.swift
//  MyFavoritePlaces
//
//  Created by Сергей Иванов on 09.10.2020.
//  Copyright © 2020 Сергей Иванов. All rights reserved.
//

import RealmSwift

class Place: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var address: String?
    @objc dynamic var type: String?
    @objc dynamic var imagePlace: Data?
    @objc dynamic var date: Date = Date()
    @objc dynamic var rating: Double = 0.0
    
    convenience init(name: String, address: String?, type: String?, imagePlace: Data?, rating: Double) {
        self.init()
        self.name = name
        self.address = address
        self.type = type
        self.imagePlace = imagePlace
        self.rating = rating
    }
}
