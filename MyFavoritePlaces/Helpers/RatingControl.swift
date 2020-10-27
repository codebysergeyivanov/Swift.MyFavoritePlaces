//
//  RatingControl.swift
//  MyFavoritePlaces
//
//  Created by Сергей Иванов on 14.10.2020.
//  Copyright © 2020 Сергей Иванов. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    var starButtons = Array<UIButton>()
    @IBInspectable var numberOfStars: Int = 5 {
        didSet {
            setButtons()
        }
    }
    @IBInspectable var starSize: CGSize = CGSize(width: 35.0, height: 35.0) {
        didSet {
            setButtons()
        }
    }
    
    var rating = 0 {
        didSet {
            updateRating()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setButtons()
    }
    
    func setButtons() {
        for button in starButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        for _ in 0..<numberOfStars {
            let button = UIButton()
            
            let star = UIImage(systemName: "star")
            let starFull = UIImage(systemName: "star.fill")
            
            button.setImage(star, for: .normal)
            button.setImage(starFull, for: .selected)
            button.setImage(starFull?.withTintColor(.red), for: .highlighted)
            button.setImage(starFull?.withTintColor(.red), for: [.selected, .highlighted])
            
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.addTarget(self, action: #selector(onTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(button)
            starButtons.append(button)
        }
        updateRating()
    }
    
    
    @objc func onTapped(button: UIButton) {
        guard let index = starButtons.firstIndex(of: button) else { return }
        let selectedStars = index + 1
        if selectedStars == rating {
            rating = 0
        } else {
            rating = selectedStars
        }
    }
    
    func updateRating() {
        for (index, btn) in starButtons.enumerated() {
            btn.isSelected = rating > index
        }
    }
}
