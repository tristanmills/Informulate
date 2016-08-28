//
//  ViewController.swift
//  Informulate
//
//  Created by Tristan Mills on 8/27/16.
//  Copyright © 2016 Tristan Mills. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let errorAlert = UIAlertController(title: nil, message: "Location Services must be enabled for this to work", preferredStyle: UIAlertControllerStyle.Alert)
    let errorAlertOkButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var whereAmIButton: UIButton!
    
    // Button Click
    @IBAction func updateLocation(sender: AnyObject) {

        // TODO: Code Style - Line Length?
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            latitudeLabel.text = "Loading..."
            longitudeLabel.text = "Loading..."
            addressLabel.text = "Loading..."
        } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
            presentViewController(errorAlert, animated: true, completion: nil)
        }

    }
    
    // Success Listener
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Async External API call
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
            (placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                self.updateLabels(placemark)
            } else {
                print("Problem with the data received from geocoder")
            }
            
        })
        
        locationManager.stopUpdatingLocation()
        
    }

    // Error Listener
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error while updating location " + error.localizedDescription)
        
        locationManager.stopUpdatingLocation()
        
    }
    
    // Update View
    func updateLabels(placemark: CLPlacemark) {
        
        let coordinates = placemark.location!.coordinate
        let address = formatAddress(placemark.addressDictionary!)
        
        latitudeLabel.text = "\(coordinates.longitude)"
        longitudeLabel.text = "\(coordinates.latitude)"
        addressLabel.text = "\(address)"
        
    }
    
    // TODO: Find a better way to format addresses
    // ABCreateStringWithAddressDictionary now depricated - replaced by CNPostalAddressFormatter
    // However, CNPostalAddressFormatter is missing the translation from CLPlacemark to CNPostalAddress
    func formatAddress(address: AnyObject) -> String {
        
        let formattedAddressLines = address["FormattedAddressLines"]! as? [String]
        let formattedAddress = formattedAddressLines!.joinWithSeparator(", ")
        
        return formattedAddress
        
    }
    
    // Innital Load
    override func viewDidLoad() {
        
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        errorAlert.addAction(errorAlertOkButton)
        
    }
    
    // TODO: Learn about memory pitfalls
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
}

