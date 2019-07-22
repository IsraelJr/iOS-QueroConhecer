//
//  PlacesTableViewController.swift
//  QueroConhecer
//
//  Created by Israel Alves Santos Junior on 16/07/19.
//  Copyright © 2019 Israel Alves Santos Junior. All rights reserved.
//

import UIKit

class PlacesTableViewController: UITableViewController {

    var places: [Place] = []
    let ud = UserDefaults.standard
    let keyUdPlace = "places"
    var lbNoPlaces: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
        
        lbNoPlaces = UILabel()
        lbNoPlaces.text = "Cadastre os locais que deseja conhecer clicando no + acima."
        lbNoPlaces.textAlignment = .center
        lbNoPlaces.numberOfLines = 0
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "finderSegue" {
            let vc = segue.destination as! PlaceFinderViewController
            vc.delegate = self
        } else {
            let vc = segue.destination as! MapViewController
            
            switch sender {
                case let place as Place:
                    vc.places = [place]
                default:
                    vc.places = places
            }
            
        }
    }

    func loadPlaces() {
        
        if let placesData  = ud.data(forKey: keyUdPlace) {
            do {
                places = try JSONDecoder().decode([Place].self, from: placesData)
                tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func savePlaces() {
        let json = try? JSONEncoder().encode(places)
        ud.set(json, forKey: keyUdPlace)
    }
    
    @objc func showAll() {
        performSegue(withIdentifier: "mapSegue", sender: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let btShowAll = UIBarButtonItem(title: "Mostrar todos no mapa", style: .plain, target: self, action: #selector(showAll))
        
        if places.count == 0 {
            navigationItem.leftBarButtonItem = nil
            tableView.backgroundView = lbNoPlaces
        } else if places.count == 1 {
            navigationItem.leftBarButtonItem = nil
            tableView.backgroundView = nil
        } else {
            navigationItem.leftBarButtonItem = btShowAll
        }
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            savePlaces()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        performSegue(withIdentifier: "mapSegue", sender: place)
    }
}



extension PlacesTableViewController: PlaceFinderDelegate {
    
    func addPlace(_ place: Place) {
        if !places.contains(place){
            places.append(place)
            savePlaces()
            tableView.reloadData()
        }
    }
    
    
}
