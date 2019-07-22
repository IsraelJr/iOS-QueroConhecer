//
//  ViewController.swift
//  QueroConhecer
//
//  Created by Israel Alves Santos Junior on 16/07/19.
//  Copyright © 2019 Israel Alves Santos Junior. All rights reserved.
//

import UIKit
import MapKit

protocol PlaceFinderDelegate: class {
    func addPlace(_ place: Place)
}

class PlaceFinderViewController: UIViewController {
    
    enum PlaceFinderMessageType {
        case error(String)
        case confirmation(String)
    }
    
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!    
    @IBOutlet weak var viLoading: UIView!
    @IBOutlet weak var btSearch: UIButton!
    
    
    var place: Place!
    weak var delegate: PlaceFinderDelegate?
    let meters: Double = 800
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_:)))
        gesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(gesture)
    }
    
    @objc func getLocation(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            load(show: true)
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                self.load(show: false)
                if error == nil {
                    if self.savePlace(with: placemarks?.first) {
                        self.showMessage(type: .error("Não foi encontrado nenhum local com esse nome."))
                    }
                } else {
                    self.showMessage(type: .error("Erro desconhecido."))
                }
            }
        }
    }

    @IBAction func findCity(_ sender: UIButton) {
        tfCity.resignFirstResponder()
        load(show: true)
        CLGeocoder().geocodeAddressString(tfCity.text!) { (placemarks, error) in
            self.load(show: false)
            if error == nil {
                if self.savePlace(with: placemarks?.first) {
                    self.showMessage(type: .error("Não foi encontrado nenhum local com esse nome."))
                }
            } else {
                self.showMessage(type: .error("Erro desconhecido."))
            }
        }
    }
    
    func savePlace(with placemark: CLPlacemark?) -> Bool {
        guard let placemark = placemark, let coordinate = placemark.location?.coordinate else {
            return false
        }
        let name = placemark.name ?? placemark.country ?? "Desconhecido"
        let address = Place.getFormattedAddress(with: placemark)
        place = Place(name: name, latitute: coordinate.latitude, longitute: coordinate.longitude, address: address)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: meters, longitudinalMeters: meters)
        mapView.setRegion(region, animated: true)
        showMessage(type: .confirmation(place.name))
        return true
    }
    
    func showMessage(type: PlaceFinderMessageType) {
        let title: String, message: String
        var hasConfirmation: Bool = false
        
        switch type {
        case .confirmation(let name):
            title = "Local Encontrado!"
            message = "Deseja adicionar \(name)?"
            hasConfirmation = true
        case .error(let errorMessage):
            title = "Erro!"
            message = errorMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        if hasConfirmation {
            let confirmationAction = UIAlertAction(title: "OK", style: .default, handler:  { (action) in
                self.delegate?.addPlace(self.place)
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(confirmationAction)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func load(show: Bool){
        viLoading.isHidden = !show
        if show {
            aiLoading.startAnimating()
        } else {
            aiLoading.stopAnimating()
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


extension PlaceFinderViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfCity {
            view.endEditing(true)
            findCity(btSearch)
        }
    return true
    }
}

