//
//  Place.swift
//  QueroConhecer
//
//  Created by Israel Alves Santos Junior on 16/07/19.
//  Copyright © 2019 Israel Alves Santos Junior. All rights reserved.
//

import Foundation
import MapKit

struct Place: Codable {
    let name: String
    let latitute: CLLocationDegrees
    let longitute: CLLocationDegrees
    let address: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitute, longitude: longitute)
    }
    
    static func getFormattedAddress(with placemark: CLPlacemark) -> String {
        var address = ""
        if let street = placemark.thoroughfare {
            address += street //-----------------------------Rua
        }
        if let number = placemark.subThoroughfare {
            address += " \(number)" //-----------------------Número
        }
        if let subLocality = placemark.subLocality {
            address += ", \(subLocality)" //-----------------Bairro
        }
        if let city = placemark.locality {
            address += "\n\(city)" //------------------------Cidade
        }
        if let state = placemark.administrativeArea {
            address += " - \(state)" //----------------------Estado
        }
        if let postalCode = placemark.postalCode {
            address += "\nCEP: \(postalCode)" //-------------CEP
        }
        if let country = placemark.country {
            address += "\n\(country)" //---------------------País
        }
        return address
    }
}

extension Place: Equatable {
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.latitute == rhs.latitute && lhs.longitute == rhs.longitute
    }
}
