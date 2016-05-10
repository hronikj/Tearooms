//
//  ViewController.swift
//  Tearooms
//
//  Created by Jiří Hroník on 23/03/16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import QuartzCore

class MainTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var tearoomCollection: [Tearoom] = []
    let tearoomHandler = TearoomAPIHandler()
    var sections = Dictionary <String, Array<Tearoom>> ()
    var sortedSections = [String]()
    var numberOfSections = Int()
    
    // for searching
    var searchResults: [Tearoom] = []
    var searchIsActive = false
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(animated: Bool) {
        downloadData()
        
        // hiding and displaying search bar
        searchController.searchBar.hidden = false
        searchController.searchBar.showsScopeBar = false
        searchController.searchBar.scopeButtonTitles = nil
        self.tableView.setContentOffset(CGPointMake(0, 44), animated: false)
        self.tableView.scrollRectToVisible(CGRectMake(0, 44, 1, 1), animated: false)
        
        let barsColor = UIColor(red:0.59, green:0.82, blue:0.38, alpha:1.00)
        self.navigationController?.navigationBar.backgroundColor = barsColor
        let statusBarView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 20))
        statusBarView.tag = 999
        statusBarView.backgroundColor = barsColor
        self.navigationController?.view.addSubview(statusBarView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.view.viewWithTag(999)?.removeFromSuperview()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.scopeButtonTitles = ["All", "City"]
        return true
    }
    
    func downloadData() {
        let tearoomAPIHandler = TearoomAPIHandler()
        tearoomAPIHandler.prepareCache()
        
        if tearoomCollection.isEmpty  {
            tearoomAPIHandler.getListofTearooms { (tearoomCollection) -> Void in
                self.tearoomCollection = tearoomCollection!
                self.splitCollectionIntoSections()
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.makeTableViewHeadersFloating()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor(red: 0.43, green: 0.77, blue: 0.14, alpha: 0.7) // the view itself
        searchController.searchBar.alpha = 1
        searchController.searchBar.searchBarStyle = .Minimal
        searchController.searchBar.placeholder = "Vyhledávání"
        searchController.searchBar.hidden = true
        searchController.searchBar.scopeButtonTitles = ["City", "All"]
        searchController.searchBar.scopeBarBackgroundImage = UIImage()
        searchController.searchBar.delegate = self
        
        // self.tableView.contentOffset = CGPointMake(0, 40)
        
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchController.searchBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        print(scope)
        searchResults = tearoomCollection.filter({ (Tearoom) -> Bool in
            switch (scope) {
                case "City":
                    return Tearoom.data[.city]!.lowercaseString.containsString(searchText.lowercaseString)
                default:
                    return (Tearoom.data[.name]?.lowercaseString.containsString(searchText.lowercaseString))!
            }
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar .scopeButtonTitles![selectedScope])
    }
    
    func makeTableViewHeadersFloating() {
        let dummyViewHeight: CGFloat = 40
        let dummyView: UIView = UIView.init(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, dummyViewHeight))
        
        self.tableView.tableHeaderView = dummyView
        self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
    }
    
    
    func splitCollectionIntoSections() {
        for asset in tearoomCollection {
            if self.sections.indexForKey(asset.data[Tearoom.fieldsDictionaryKeysForAPI.city] as! String) == nil {
                self.sections[asset.data[Tearoom.fieldsDictionaryKeysForAPI.city] as! String] = [asset]
            } else {
                self.sections[asset.data[Tearoom.fieldsDictionaryKeysForAPI.city] as! String]!.append(asset)
            }
        }
        
        self.sortedSections = self.sections.keys.sort()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return 1
        }
        
        return self.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return searchResults.count
        }
        
        return self.sections[sortedSections[section]]!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MainTableViewCellIdentifier"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MainTableViewCell
        
        let tableSection = sections[sortedSections[indexPath.section]]
        
        let cellData = (searchController.active && searchController.searchBar.text != "") ? searchResults[indexPath.row] : tableSection![indexPath.row]
                
        if let tearoomNameLabel = cellData.data[.name] as? String {
            cell.nameLabel.text = tearoomNameLabel
        } else {
            cell.nameLabel.text = ""
            print("Couldn't unwrap cellData.data[.name]!")
        }
        
        if cellData.isOpenNow(cellData) {
            cell.openFromLabel.text = "Otevřeno"
            
            // get opening time for today
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE"
            let dayOfTheWeek = dateFormatter.stringFromDate(NSDate())

            let openingTime = self.tearoomHandler.openingTimeDateFormatter.stringFromDate(cellData.getOpeningTimeForDay(dayOfTheWeek, closing: false)!)
            cell.openFromLabel.text = "Otevřeno do " + openingTime

        } else {
            cell.openFromLabel.text = "Zavřeno"
            
            // construct tomorrow date and format it
            let calendar = NSCalendar.currentCalendar()
            if let tomorrow = calendar.dateByAddingUnit(.Day, value: 1, toDate: NSDate(), options: []) {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEEE"
                
                let dayOfTheWeek = dateFormatter.stringFromDate(tomorrow)
                let openingTime = self.tearoomHandler.openingTimeDateFormatter.stringFromDate(cellData.getOpeningTimeForDay(dayOfTheWeek, closing: false)!)
                cell.openFromLabel.text = "Otevírá zítra v " + openingTime
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.active && searchController.searchBar.text != "" {
            return "Vyhledávání"
        }
        
        return sortedSections[section]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "TearoomDetailSegueIdentifier":
                if let destinationViewController = segue.destinationViewController as? DetailViewController {
                    if let selectedCell = sender as? MainTableViewCell {
                        let indexPath = tableView.indexPathForCell(selectedCell)
                        let tableSection = sections[sortedSections[(indexPath?.section)!]]
                        let cellData = (searchController.active && searchController.searchBar.text != "") ? searchResults[indexPath!.row] : tableSection![indexPath!.row]
                        
                        if let locationLatitude = cellData.data[.locationLatitude]?.doubleValue {
                            if let locationLongitude = cellData.data[.locationLongitude]?.doubleValue {
                                destinationViewController.location = CLLocationCoordinate2DMake(locationLatitude, locationLongitude)
                            }
                        }
                        
                        let openingDays: [String: Tearoom.OpeningTimesKeysForDictionary] = [
                            "Monday":       .MondayOpeningTime,
                            "Tuesday":      .TuesdayOpeningTime,
                            "Wednesday":    .WednesdayOpeningTime,
                            "Thursday":     .ThursdayOpeningTime,
                            "Friday":       .FridayOpeningTime,
                            "Saturday":     .SaturdayOpeningTime,
                            "Sunday":       .SundayOpeningTime
                        ]
                        
                        let closingDays: [String: Tearoom.OpeningTimesKeysForDictionary] = [
                            "Monday":       .MondayClosingTime,
                            "Tuesday":      .TuesdayClosingTime,
                            "Wednesday":    .WednesdayClosingTime,
                            "Thursday":     .ThursdayClosingTime,
                            "Friday":       .FridayClosingTime,
                            "Saturday":     .SaturdayClosingTime,
                            "Sunday":       .SundayClosingTime
                        ]
                        
                        let openingTimeDateFormatter = TearoomAPIHandler().openingTimeDateFormatter
                        
                        for openingDay in openingDays {
                            if let openingDate = cellData.getOpeningTimeForDay(openingDay.0, closing: false) {
                                let openingTimeString = openingTimeDateFormatter.stringFromDate(openingDate)
                                destinationViewController.openingTimes[openingDay.1] = openingTimeString
                            }
                        }
                        
                        for closingDay in closingDays {
                            if let closingDate = cellData.getOpeningTimeForDay(closingDay.0, closing: true) {
                                let closingTimeString = openingTimeDateFormatter.stringFromDate(closingDate)
                                destinationViewController.openingTimes[closingDay.1] = closingTimeString
                            }
                        }
                        
                        if let tearoomName = cellData.data[.name] as? String {
                            destinationViewController.name = tearoomName
                        }
                        
                        if let tearoomStreet = cellData.data[.street] as? String,
                            tearoomZipcode = cellData.data[.zipcode] as? String,
                            tearoomCity = cellData.data[.city] as? String
                        {
                            destinationViewController.address = "\(tearoomStreet)\n\(tearoomZipcode)\n\(tearoomCity)"
                        }
                    }
                }
                
                break
            
            case "ShowMapSegueIdentifier":
                if let destinationViewController = segue.destinationViewController as? MapViewController {
                    destinationViewController.tearoomCollection = tearoomCollection
                }
                
                break
                
            default:
                break
            } // end of switch
        }
    }
}

