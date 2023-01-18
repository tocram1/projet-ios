//
//  MapsController.swift
//  SamyTheoProjet
//
//  Created by etudiant on 22/09/2022.
//

import Foundation
//
//  SecondController.swift
//  SamyTheoProjet
//
//  Created by etudiant on 21/09/2022.
//

import Foundation
import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation

class MapsController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    private let database = Database.database().reference()
    
    private let locationManager = CLLocationManager()
    private var oldPos: Position!
    @IBOutlet weak var MapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapView.showsUserLocation = true
        MapView.isZoomEnabled = true
        MapView.isScrollEnabled = true
        self.locationManager.requestWhenInUseAuthorization()
        
        if(CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
            // chopper la position actuelle
            if let coor = MapView.userLocation.location?.coordinate{
                let posObject : NSDictionary = [
                    "long": coor.longitude,
                    "lat": coor.latitude
                ]
                
                // récupérer l'ancienne position
                database.child(UIDevice.current.identifierForVendor!.uuidString).getData(completion:  { error, resPos in
                    guard error == nil else {
                      print("Error: ", error!.localizedDescription)
                      return;
                    }
                    let myStringDict = resPos?.value as? [String:Double]

                    self.oldPos = Position(long: myStringDict?["long"] ?? 0.0, lat: myStringDict?["lat"] ?? 0.0)
                });
                
                // enregistrer la nouvelle position
                database.child(UIDevice.current.identifierForVendor!.uuidString).setValue(posObject)
                let newLocation = CLLocation(latitude: posObject.value(forKey: "lat") as! CLLocationDegrees, longitude: posObject.value(forKey: "long") as! CLLocationDegrees)
                MapView.centerToLocation(newLocation)
            
        }
    }
    @IBAction func onClickGoToLastPosition(_ sender: Any) {
        var initialLocation = CLLocation(latitude: 49.83714, longitude: 3.2999)
        if(oldPos != nil) {
             initialLocation = CLLocation(latitude: oldPos.lat, longitude: oldPos.long)
        }
        MapView.centerToLocation(initialLocation)
    }
}


private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(
        center : location.coordinate,
        latitudinalMeters: regionRadius,
        longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

struct Position {
    var long: Double
    var lat: Double
}
