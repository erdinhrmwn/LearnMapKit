//
//  ViewController.swift
//  LearnMapkit
//
//  Created by sarkom-2 on 14/05/19.
//  Copyright © 2019 sarkom-2. All rights reserved.
//

import Alamofire
import MapKit
import SwiftyJSON
import UIKit

class costumPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(pinTitle: String, pinSubtitle: String, location: CLLocationCoordinate2D) {
        title = pinTitle
        subtitle = pinSubtitle
        coordinate = location
    }
}

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var startLocation: UITextField!
    @IBOutlet var endLocation: UITextField!

    var places: [Places] = []
    var selectedPlaces: [Int] = []

    var nameSource: String?
    var latitudeSource: Double?
    var longitudeSource: Double?
    var nameDestination: String?
    var latitudeDestination: Double?
    var longitudeDestination: Double?

    var startLocationName: String?
    var endLocationName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        request()

        startLocation.text = startLocationName
        endLocation.text = endLocationName

        startLocation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectStartLocation)))
        endLocation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectEndLocation)))
    }

    override func viewWillAppear(_ animated: Bool) {
        print(selectedPlaces)
    }

    @objc func selectStartLocation() {
        if !startLocation.text!.isEmpty && endLocation.text!.isEmpty {
            selectedPlaces.remove(at: 0)
        }

        if selectedPlaces.count == 2 {
            selectedPlaces.removeFirst()
        }

        let controller = storyboard?.instantiateViewController(withIdentifier: "tableViewController") as! TableViewController
        controller.selectedPlaces = selectedPlaces
        if endLocationName != nil {
            controller.endLocationName = endLocationName
        }
        controller.typeLocation = "start"
        present(controller, animated: true, completion: nil)
    }

    @objc func selectEndLocation() {
        if !startLocation.text!.isEmpty && !endLocation.text!.isEmpty {
            selectedPlaces.remove(at: 1)
        } else if !endLocation.text!.isEmpty && startLocation.text!.isEmpty {
            selectedPlaces.remove(at: 0)
        }

        if selectedPlaces.count == 2 {
            selectedPlaces.removeLast()
        }

        let controller = storyboard?.instantiateViewController(withIdentifier: "tableViewController") as! TableViewController
        controller.selectedPlaces = selectedPlaces
        if startLocationName != nil {
            controller.startLocationName = startLocationName
        }
        controller.typeLocation = "end"
        present(controller, animated: true, completion: nil)
    }

    @IBAction func goButton(_ sender: UIButton) {
        if selectedPlaces.count == 2 {
            let placeDestination = places[selectedPlaces[1] - 1]
            nameDestination = placeDestination.name!
            latitudeDestination = placeDestination.latitude!
            longitudeDestination = placeDestination.longitude!

            let placeSource = places[selectedPlaces[0] - 1]
            nameSource = placeSource.name
            latitudeSource = placeSource.latitude
            longitudeSource = placeSource.longitude
        } else if selectedPlaces.count == 1 {
            let place = places[selectedPlaces[0] - 1]
            nameSource = place.name
            latitudeSource = place.latitude
            longitudeSource = place.longitude
        }
        setupNewView(nameSource ?? "", latitudeSource: latitudeSource ?? -6.1647626, longitudeSource: longitudeSource ?? 106.7627832, nameDestination: nameDestination ?? "INTRA Training Center", latitudeDestination: latitudeDestination ?? -6.1647626, longitudeDestination: longitudeDestination ?? 106.7627832)
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
            }
        }
    }

    func setupNewView(_ nameSource: String, latitudeSource: Double, longitudeSource: Double, nameDestination: String, latitudeDestination: Double, longitudeDestination: Double) {
        let sourceLocation = CLLocationCoordinate2D(latitude: latitudeSource, longitude: longitudeSource)
        let destinationLocation = CLLocationCoordinate2D(latitude: latitudeDestination, longitude: longitudeDestination)

        let sourcePin = costumPin(pinTitle: nameSource, pinSubtitle: "", location: sourceLocation)
        let destinationPin = costumPin(pinTitle: nameDestination, pinSubtitle: "", location: destinationLocation)

        mapView.addAnnotation(sourcePin)
        mapView.addAnnotation(destinationPin)

        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)

        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile

        let direction = MKDirections(request: directionRequest)
        direction.calculate { response, error in
            guard let directionResponse = response else {
                if error != nil {
                    print("We had error getting \(error!.localizedDescription)")
                }
                return
            }

            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)

            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }

        mapView.delegate = self
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 4

        return renderer
    }

    func setupView() {
        // 1
        let location = CLLocationCoordinate2D(latitude: -6.1647626, longitude: 106.7627832)

        // 2
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)

        // 3
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "INTRA Training Center"
        annotation.subtitle = "\(location.latitude)"
        mapView.addAnnotation(annotation)
        mapView.mapType = .satellite
    }
}
