//
//  MapViewController.swift
//  Tearooms
//
//  Created by Jiří Hroník on 30/03/16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    var tearoomCollection: [Tearoom] = []

    override func viewDidLoad() {
        let coordinate = CLLocationCoordinate2DMake(49.19506, 16.606837)
        let span = MKCoordinateSpanMake(0.003, 0.003)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        
        mapView.delegate = self
        mapView.setRegion(region, animated: true)
        
//        addAnnotations()
    }
    
//    func addAnnotations() {
//        for tearoom in tearoomCollection {
//            let location = CLLocationCoordinate2D(latitude: tearoom.location_latitude, longitude: tearoom.location_longitude)
//            
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = location
//            annotation.title = tearoom.name
//            // annotation.subtitle = String(tearoom.open.from)
//        
//            mapView.addAnnotation(annotation)
//        }
//    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        let detailButton: UIButton = UIButton(type: UIButtonType.DetailDisclosure)
        
        // Reuse the annotation if possible
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView = detailButton
            annotationView?.image = UIImage(named: "pin")
        }
        else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowDetailFromMapSegueIdentifier") {
            if let destinationViewController = segue.destinationViewController as? DetailViewController {
                
                if let annotation = sender as? String {
                    // destinationViewController.setLabel("\(annotation) (from the map)")
                    destinationViewController.name = "\(annotation) (from the map)"
                }
            }
        }
    }

    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            print("Button tapped!")
            performSegueWithIdentifier("ShowDetailFromMapSegueIdentifier", sender: view.annotation!.title!)
        }
    }
    
}