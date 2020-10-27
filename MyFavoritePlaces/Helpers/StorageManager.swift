//
//  StorageManager.swift
//  MyFavoritePlaces
//
//  Created by Сергей Иванов on 11.10.2020.
//  Copyright © 2020 Сергей Иванов. All rights reserved.
//

import RealmSwift
let realm = try! Realm()

class StorageManager {
   static func addObject(_ object: Place) {
        try! realm.write {
            realm.add(object)
        }
    }
    static func removeObject(_ object: Place) {
        try! realm.write {
            realm.delete(object)
        }
    }
}
