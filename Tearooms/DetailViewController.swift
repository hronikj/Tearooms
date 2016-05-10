//
//  DetailViewController.swift
//  Tearooms
//
//  Created by Jiří Hroník on 29/03/16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mondayOpeningTimeLabel: UILabel!
    @IBOutlet weak var mondayClosingTimeLabel: UILabel!
    @IBOutlet weak var tuesdayOpeningTimeLabel: UILabel!
    @IBOutlet weak var tuesdayClosingTimeLabel: UILabel!
    @IBOutlet weak var wednesdayOpeningTimeLabel: UILabel!
    @IBOutlet weak var wednesdayClosingTimeLabel: UILabel!
    @IBOutlet weak var thursdayOpeningTimeLabel: UILabel!
    @IBOutlet weak var thursdayClosingTimeLabel: UILabel!
    @IBOutlet weak var fridayOpeningTimeLabel: UILabel!
    @IBOutlet weak var fridayClosingTimeLabel: UILabel!
    @IBOutlet weak var saturdayOpeningTimeLabel: UILabel!
    @IBOutlet weak var saturdayClosingTimeLabel: UILabel!
    @IBOutlet weak var sundayOpeningTimeLabel: UILabel!
    @IBOutlet weak var sundayClosingTimeLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var name = String()
    var location = CLLocationCoordinate2D()
    var tearoomLocation = CLLocationCoordinate2D()
    var address = String()
    var openingTimes: [Tearoom.OpeningTimesKeysForDictionary: String] = [:]
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.nameLabel.text = self.name
        self.addressLabel.text = self.address
        
        let openingTimesDictionary: [Tearoom.OpeningTimesKeysForDictionary: UILabel] = [
            .MondayOpeningTime: mondayOpeningTimeLabel,
            .MondayClosingTime: mondayClosingTimeLabel,
            .TuesdayOpeningTime: tuesdayOpeningTimeLabel,
            .TuesdayClosingTime: tuesdayClosingTimeLabel,
            .WednesdayOpeningTime: wednesdayOpeningTimeLabel,
            .WednesdayClosingTime: wednesdayClosingTimeLabel,
            .ThursdayOpeningTime: thursdayOpeningTimeLabel,
            .ThursdayClosingTime: thursdayClosingTimeLabel,
            .FridayOpeningTime: fridayOpeningTimeLabel,
            .FridayClosingTime: fridayClosingTimeLabel,
            .SaturdayOpeningTime: saturdayOpeningTimeLabel,
            .SaturdayClosingTime: saturdayClosingTimeLabel,
            .SundayOpeningTime: sundayOpeningTimeLabel,
            .SundayClosingTime: sundayClosingTimeLabel
        ]
        
        for openingTime in openingTimesDictionary {
            openingTime.1.text = openingTimes[openingTime.0]
        }
        
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.43, green: 0.77, blue: 0.14, alpha: 0.7)
    }
    
    override func viewWillDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomToRegion(self.location)
        print("Location from viewDidLoad:\(location)")
        // getLocation()
    }
    
    func getLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Inside didUpdateLocations")
        print(manager.location?.coordinate)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
        print("Updating location...")
        if let locationValue = manager.location?.coordinate {
            print("Current location is: \(locationValue.latitude) \(locationValue.longitude)")
            self.location = (manager.location?.coordinate)!
            
            // zoom to region
            print("Zooming to region...")
            zoomToRegion(locationValue)
        } else {
            print("Could not obtain location...")
        }
    }
    
    func addAnnotation(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        let annotation = CustomPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = coordinate
        annotation.imageName = "EmptyFlag"
        
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print("Delegate Called")
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "annotation"
        var viewForAnnotation = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if viewForAnnotation == nil {
            viewForAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            viewForAnnotation?.canShowCallout = true
        } else {
            viewForAnnotation?.annotation = annotation
        }
        
        // image name
        let image = UIImage(named: "TeapotFilled")
        
        // make image half of the size
        let size = CGSizeApplyAffineTransform((image?.size)!, CGAffineTransformMakeScale(0.5, 0.5))
        let hasAlplha = false
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(size, hasAlplha, scale)
        image?.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        viewForAnnotation?.image = scaledImage
        return viewForAnnotation
    }
    
    func zoomToRegion(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1500.0, 1500.0)
        mapView.setRegion(region, animated: true)
        
        print("Location from zoomToRegion:\(location)")
        // add annotation
        addAnnotation(name, subtitle: address, coordinate: coordinate)
    }
        
}