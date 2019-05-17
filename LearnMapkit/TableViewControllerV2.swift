//
//  TableViewController.swift
//  LearnMapkit
//
//  Created by sarkom-2 on 15/05/19.
//  Copyright © 2019 sarkom-2. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

class TableViewControllerV2: UITableViewController {
    var places: [Places] = []
    var selectedPlaces: [Int] = []

    var typeLocation: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        //        tableView.allowsMultipleSelection = true
        request()
    }

    func request() {
        AF.request("http://192.168.64.2/restaurant/places.php").responseJSON { response in
            let json = JSON(response.value!)
            let data = json.arrayValue
            for i in data {
                let id = i["id"].intValue
                let name = i["title"].stringValue
                let latitude = i["latitude"].doubleValue
                let longitude = i["longitude"].doubleValue

                let placesData = Places(id: id, name: name, latitude: latitude, longitude: longitude)

                self.places.append(placesData)
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func nextButton(_ sender: UIBarButtonItem) {
        let viewController = ViewController()

        if selectedPlaces.count == 2 {
            let place = places[selectedPlaces[1] - 1]
            viewController.nameDestination = place.name!
            viewController.latitudeDestination = place.latitude!
            viewController.longitudeDestination = place.longitude!
        } else {
            let place = places[selectedPlaces[0] - 1]
            viewController.nameSource = place.name
            viewController.latitudeSource = place.latitude
            viewController.longitudeSource = place.longitude
        }

        present(viewController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let place = places[indexPath.row]

        // Configure the cell...
        cell.textLabel!.text = place.name
        cell.detailTextLabel!.text = "\(place.latitude!)"

        if cell.isSelected {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = tableView.cellForRow(at: indexPath)
        let viewController = storyboard?.instantiateViewController(withIdentifier: "viewController") as! ViewController
        let place = places[indexPath.row]
        selectedPlaces.append(place.id!)
        print(viewController.selectedPlaces)
        viewController.selectedPlaces = selectedPlaces
        if viewController.selectedPlaces.count == 2 {
            viewController.selectedPlaces.removeLast()
        }
        viewController.endLocationName = place.name
        present(viewController, animated: true, completion: nil)

        //        if selectedPlaces.count <= 1 {
        //            selectedPlaces.append(place.id!)
        //            cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
        //        }
    }

//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
//        let place = places[indexPath.row]
//
//        if let i = selectedPlaces.firstIndex(of: place.id!) {
//            selectedPlaces.remove(at: i)
//            cell!.accessoryType = UITableViewCell.AccessoryType.none
//        }
//    }
}
