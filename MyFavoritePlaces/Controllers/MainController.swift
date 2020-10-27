//
//  MainController.swift
//  MyFavoritePlaces
//
//  Created by Сергей Иванов on 08.10.2020.
//  Copyright © 2020 Сергей Иванов. All rights reserved.
//

import UIKit
import RealmSwift

class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let searchController = UISearchController(searchResultsController: nil)
    var isAscending: Bool = true
    var myPlaces: Results<Place>!
    var filtredPlaces: Results<Place>!
    var isSearching: Bool {
        guard let text = searchController.searchBar.text else { return false }
        let isSearchTextEmpty = text.isEmpty
        return searchController.isActive && !isSearchTextEmpty
    }

    @IBOutlet weak var ascendingButtom: UIBarButtonItem!
    @IBOutlet weak var segmentedControler: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        myPlaces = realm.objects(Place.self)
        tableView.tableFooterView = UIView()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isSearching {
            return filtredPlaces.count
        }
        return myPlaces.isEmpty ? 0 : myPlaces.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
        var place: Place
        if isSearching {
            place = filtredPlaces[indexPath.row]
        } else {
            place = myPlaces[indexPath.row]
        }
        cell.name.text = place.name
        cell.address.text = place.address
        cell.type.text = place.type
        cell.img.layer.cornerRadius = cell.img.frame.size.height / 2
        cell.clipsToBounds = true
        cell.img.image = UIImage(data: place.imagePlace!)
        cell.rating.rating = Double(place.rating)
    
        return cell
    }
    
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if (editingStyle == .delete) {
                StorageManager.removeObject(myPlaces[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }

    @IBAction func setAscending(_ sender: UIBarButtonItem) {
        isAscending.toggle()
        
        if isAscending {
            ascendingButtom.image = UIImage(systemName: "arrow.up")
        } else {
            ascendingButtom.image = UIImage(systemName: "arrow.down")
        }
        sorted()
    }
    @IBAction func selectedSort(_ sender: UISegmentedControl) {
       sorted()
    }
    
    func sorted() {
        if segmentedControler.selectedSegmentIndex == 0 {
            myPlaces = myPlaces.sorted(byKeyPath: "name", ascending: isAscending)
        } else {
            myPlaces = myPlaces.sorted(byKeyPath: "date", ascending: isAscending)
        }
        tableView.reloadData()
    }
    @IBAction func unwindToMainController(_ unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier != "save" { return }
        guard let svc = unwindSegue.source as? PlaceDetailsController else { return }
        svc.saveNewPlace()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard segue.identifier == "edit" else { return }
        guard let dvc = segue.destination as? PlaceDetailsController else { return }
        var place: Place
        if isSearching {
            place = filtredPlaces[indexPath.row]
        } else {
            place = myPlaces[indexPath.row]
        }
        dvc.currentPlace = place
    }
}

extension MainController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        onChangeSearchText(text: searchController.searchBar.text!)
    }
    func onChangeSearchText(text: String) {
        filtredPlaces = myPlaces.filter("name CONTAINS[c] %@ OR address CONTAINS[c] %@", text, text)
        tableView.reloadData()
    }
}
