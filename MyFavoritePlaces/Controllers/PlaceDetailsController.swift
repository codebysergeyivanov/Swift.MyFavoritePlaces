//
//  PlaceDetailsController.swift
//  MyFavoritePlaces
//
//  Created by Сергей Иванов on 10.10.2020.
//  Copyright © 2020 Сергей Иванов. All rights reserved.
//

import UIKit
import RealmSwift

class PlaceDetailsController: UITableViewController, UINavigationControllerDelegate {
    
    var currentPlace: Place!
    
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var save: UIBarButtonItem!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var type: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        save.isEnabled = false
        name.addTarget(self, action: #selector(onNameChanged), for: .editingChanged)
        setupHeaderBar()
        setDataForEditing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        let cameraIcon = UIImage(systemName: "camera")
        let photoIcon = UIImage(systemName: "photo")
    
        if indexPath.row == 0 {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default, handler: { _ in self.pickImage(source: .camera)})
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            camera.setValue(cameraIcon, forKey: "image")
            let photos = UIAlertAction(title: "Photos", style: .default, handler: { _ in self.pickImage(source: .photoLibrary)})
            photos.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            photos.setValue(photoIcon, forKey: "image")
            let chancel = UIAlertAction(title: "Chancel", style: .cancel, handler: nil)
            actionSheet.addAction(camera)
            actionSheet.addAction(photos)
            actionSheet.addAction(chancel)
            present(actionSheet, animated: true)
        }
    }
    
    func setupHeaderBar() {
        if currentPlace != nil {
            guard let topItem = navigationController?.navigationBar.topItem else { return }
            navigationItem.leftBarButtonItem = nil
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            save.isEnabled = true
            navigationItem.title = currentPlace?.name
        }
    }
    func setDataForEditing() {
        guard let imagePlaceData = currentPlace?.imagePlace else { return }
        if currentPlace != nil {
            name.text = currentPlace?.name
            address.text = currentPlace?.address
            type.text = currentPlace?.type
            ratingControl.rating = Int(currentPlace.rating)
            image.image = UIImage(data: imagePlaceData)
        }
    }
    
    func saveNewPlace() -> Void {
        if currentPlace != nil {
            print("jefdsa")
            try! realm.write {
                currentPlace?.name = name.text!
                currentPlace?.address = address.text!
                currentPlace?.type = type.text!
                currentPlace?.imagePlace = image.image?.pngData()
                currentPlace?.rating = Double(ratingControl.rating)
            }
        } else {
            let newPlace = Place(
                name: name.text!,
                address: address.text,
                type: type.text,
                imagePlace: image?.image?.pngData(),
                rating: Double(ratingControl.rating)
            )
            StorageManager.addObject(newPlace)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifierSegue = segue.identifier else { return }
        guard let mvc = segue.destination as? MapController else {
            return
        }
        mvc.identifierSegue = identifierSegue
        if identifierSegue == "setPlace" {
            mvc.mapControllerDelegate = self
        }
        mvc.place.name = name.text!
        mvc.place.address = address.text
        mvc.place.type = type.text
        mvc.place.imagePlace = image?.image?.pngData()
        mvc.identifierSegue = identifierSegue
    }
}

extension PlaceDetailsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func onNameChanged() -> Void {
        if name.text?.isEmpty == true {
            save.isEnabled = false
        } else {
            save.isEnabled = true
        }
    }
}

extension PlaceDetailsController: UIImagePickerControllerDelegate {
    func pickImage(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        image.contentMode = .scaleAspectFit
        image.image = chosenImage
        dismiss(animated: true)
    }
}

extension PlaceDetailsController: MapControllerDelegate {
    func getAddress(_ address: String?) {
        self.address.text = address
    }
}
