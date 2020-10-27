//
//  MainCell.swift
//  MyFavoritePlaces
//
//  Created by Сергей Иванов on 08.10.2020.
//  Copyright © 2020 Сергей Иванов. All rights reserved.
//

import UIKit
import Cosmos

class MainCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var rating: CosmosView!
    
}
