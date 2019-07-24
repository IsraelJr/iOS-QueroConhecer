//
//  MapViewController.swift
//  QueroConhecer
//
//  Created by Israel Alves Santos Junior on 16/07/19.
//  Copyright © 2019 Israel Alves Santos Junior. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    enum MapMessageType {
        case routeError
        case authorizationWarning
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var places: [Place]!
    var poi: [MKAnnotation] = []
    lazy var locationManager = CLLocationManager()
    var btUserLocation: MKUserTrackingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden          = true
        mapView.mapType             = .mutedStandard
        viInfo.isHidden             = true
        mapView.delegate            = self
        locationManager.delegate    = self
        
        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus lugares"
        }
        
        for place in places {
            addToMap(place)
        }
        
        configureLocationButton()
        showPlaces()
        requestUserLocationAuthorization()
        
    }
    
    func configureLocationButton() {
        btUserLocation = MKUserTrackingButton(mapView: mapView)
        btUserLocation.backgroundColor      = .white
        btUserLocation.frame.origin.x       = 10
        btUserLocation.frame.origin.y       = 10
        btUserLocation.layer.cornerRadius   = 5
        btUserLocation.layer.borderWidth    = 1
        btUserLocation.layer.borderColor    = UIColor(named: "main")?.cgColor
        
    }
    
    func requestUserLocationAuthorization() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.addSubview(btUserLocation)
                
            case .denied:
                showMessage(type: .authorizationWarning)
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            case .restricted:
                break
            
            default:
                break
            }
        } else {
            //Nada
        }
    }
    
    func addToMap(_ place: Place) {
        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
        annotation.title = place.name
        annotation.address = place.address
        mapView.addAnnotation(annotation)
    }
    
    func showMessage(type: MapMessageType) {
//        let title: String, message: String
//        var hasConfirmation: Bool = false
//
//        switch type {
//        case .confirmation(let name):
//            title = "Local Encontrado!"
//            message = "Deseja adicionar \(name)?"
//            hasConfirmation = true
//        case .error(let errorMessage):
//            title = "Erro!"
//            message = errorMessage
//        }
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
//        alert.addAction(cancelAction)
//
//        if hasConfirmation {
//            let confirmationAction = UIAlertAction(title: "OK", style: .default, handler:  { (action) in
//                self.delegate?.addPlace(self.place)
//                self.dismiss(animated: true, completion: nil)
//            })
//            alert.addAction(confirmationAction)
//        }
//        present(alert, animated: true, completion: nil)
    }
    
    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    @IBAction func showRoute(_ sender: UIButton) {
    }
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is PlaceAnnotation) {
            return nil
        }
        let type = (annotation as! PlaceAnnotation).type
        let identifier = "\(type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.annotation      = annotation
        annotationView?.canShowCallout  = true
        annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "poi")
        annotationView?.glyphImage      = type == .place ? UIImage(named: "placeGlyph") : UIImage(named: "poiGlyph")
        annotationView?.displayPriority = type == .place ? .required : .defaultHigh
        
        return annotationView
    }
}


extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        loading.startAnimating()
        
        let request                     = MKLocalSearch.Request()
        request.naturalLanguageQuery    = searchBar.text
        request.region                  = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                guard let response  = response else {
                    self.loading.stopAnimating()
                    return
                }
                self.mapView.removeAnnotations(self.poi)
                self.poi.removeAll()
                for item in response.mapItems {
                    let annotation      = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .poi)
                    annotation.title    = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.address  = Place.getFormattedAddress(with: item.placemark)
                    self.poi.append(annotation)
                }
                self.mapView.addAnnotations(self.poi)
                self.mapView.showAnnotations(self.poi, animated: true)
            }
            self.loading.stopAnimating()
        }
    }
    
}


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            mapView.addSubview(btUserLocation)
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Última localização do usuário: \(String(describing: locations.last))")
    }
    
    
}
