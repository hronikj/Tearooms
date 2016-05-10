//
//  TearoomsAPI.swift
//  Tearooms
//
//  Created by Jiří Hroník on 25/03/16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TearoomAPIHandler {
    private let apiURLBase = "http://private-4b36e-tearooms.apiary-mock.com"
    internal let openingTimeDateFormatter = NSDateFormatter()
    
    private let fieldsDictionaryForAPI: [Tearoom.fieldsDictionaryKeysForAPI: AnyObject] = [
        Tearoom.fieldsDictionaryKeysForAPI.name: "name",
        Tearoom.fieldsDictionaryKeysForAPI.city: "city",
        Tearoom.fieldsDictionaryKeysForAPI.locationLatitude: "location_latitude",
        Tearoom.fieldsDictionaryKeysForAPI.locationLongitude: "location_longitude",
        Tearoom.fieldsDictionaryKeysForAPI.id: "id",
        Tearoom.fieldsDictionaryKeysForAPI.street: "street",
        Tearoom.fieldsDictionaryKeysForAPI.zipcode: "zipcode",
        Tearoom.fieldsDictionaryKeysForAPI.OpeningTimeForMonday: ["opening", "monday", "from"],
        Tearoom.fieldsDictionaryKeysForAPI.ClosingTimeForMonday: ["opening", "monday", "to"],
        Tearoom.fieldsDictionaryKeysForAPI.OpensInMonday: ["opening", "monday", "open"],
        Tearoom.fieldsDictionaryKeysForAPI.OpeningTimeForTuesday: ["opening", "tuesday", "from"],
        Tearoom.fieldsDictionaryKeysForAPI.ClosingTimeForTuesday: ["opening", "tuesday", "to"],
        Tearoom.fieldsDictionaryKeysForAPI.OpensInTuesday: ["opening", "tuesday", "open"],
        Tearoom.fieldsDictionaryKeysForAPI.OpeningTimeForWednesday: ["opening", "wednesday", "from"],
        Tearoom.fieldsDictionaryKeysForAPI.ClosingTimeForWednesday: ["opening", "wednesday", "to"],
        Tearoom.fieldsDictionaryKeysForAPI.OpensInWednesday: ["opening", "wednesday", "open"],
        Tearoom.fieldsDictionaryKeysForAPI.OpeningTimeForThursday: ["opening", "thursday", "from"],
        Tearoom.fieldsDictionaryKeysForAPI.ClosingTimeForThursday: ["opening", "thursday", "to"],
        Tearoom.fieldsDictionaryKeysForAPI.OpensInThursday: ["opening", "thursday", "open"],
        Tearoom.fieldsDictionaryKeysForAPI.OpeningTimeForFriday: ["opening", "friday", "from"],
        Tearoom.fieldsDictionaryKeysForAPI.ClosingTimeForFriday: ["opening", "friday", "to"],
        Tearoom.fieldsDictionaryKeysForAPI.OpensInFriday: ["opening", "friday", "open"],
        Tearoom.fieldsDictionaryKeysForAPI.OpeningTimeForSaturday: ["opening", "saturday", "from"],
        Tearoom.fieldsDictionaryKeysForAPI.ClosingTimeForSaturday: ["opening", "saturday", "to"],
        Tearoom.fieldsDictionaryKeysForAPI.OpensInSaturday: ["opening", "saturday", "open"],
        Tearoom.fieldsDictionaryKeysForAPI.OpeningTimeForSunday: ["opening", "sunday", "from"],
        Tearoom.fieldsDictionaryKeysForAPI.ClosingTimeForSunday: ["opening", "sunday", "to"],
        Tearoom.fieldsDictionaryKeysForAPI.OpensInSunday: ["opening", "sunday", "open"]
    ]
    
    init () {
        openingTimeDateFormatter.dateFormat = "H:mm"
    }
    
    private func unwrapOptionalsFromJSON(json: JSON) -> [Tearoom] {
        var tearoomCollection: [Tearoom] = []
        
        for (String: _, JSON: subJSON) in json {
            // unwrap optionals from JSON
            var tearoomDictionary: [Tearoom.fieldsDictionaryKeysForAPI: AnyObject] = [:]
            
            for field in fieldsDictionaryForAPI {
                // unwrap strings
                if let unwrappedStringFromJSON = subJSON[String(field.1)].string {
                    tearoomDictionary[field.0] = unwrappedStringFromJSON
                }
                
                // unwrap bools
                if let unwrappedBoolFromJSON = subJSON[String(field.1[0]), String(field.1[1]), String(field.1[2])].bool  {
                    tearoomDictionary[field.0] = unwrappedBoolFromJSON
                }
                
                // unwrap integers
                if let unwrappedIntFromJSON = subJSON[String(field.1)].int {
                    tearoomDictionary[field.0] = unwrappedIntFromJSON
                }
                
                // unwrap opening times (arrays)
                if let unwrappedStringFromJSON = subJSON[String(field.1[0]), String(field.1[1]), String(field.1[2])].string {
                    tearoomDictionary[field.0] = unwrappedStringFromJSON
                    if let openingTimeDate = convertOpeningTimeStringToDate(unwrappedStringFromJSON) {
                        tearoomDictionary[field.0] = openingTimeDate
                    }
                }
                
            }
            
            let tearoom = Tearoom(data: tearoomDictionary)
            tearoomCollection.append(tearoom)
        }
    
        return tearoomCollection
    }
    
    private func convertOpeningTimeStringToDate(openingTimeString: String) -> NSDate? {
        if let openingTimeDate = self.openingTimeDateFormatter.dateFromString(openingTimeString) {
            return openingTimeDate
        }
        
        return nil
    }
    
    func getListofTearooms(completionHandler: ([Tearoom]?) -> ()) -> () {
        let apiURLComponent = "/tearooms"
        let requestURL = "\(apiURLBase)\(apiURLComponent)"
        var tearoomCollection: [Tearoom] = []
        
        Alamofire.request(.GET, requestURL).responseJSON {
            response in
            if let jsonResponse = response.result.value {
                let json = JSON(jsonResponse)
                tearoomCollection = self.unwrapOptionalsFromJSON(json)

            }
            
            completionHandler(tearoomCollection)
        }
    }
    
    func prepareCache () {
        let memoryCapacity = 500 * 1024 * 1024 // 500 MB
        let diskCapacity = 500 * 1024 * 1024 // 500 MB
        let cache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "shared_cache")
        
        let configuration =  NSURLSessionConfiguration.defaultSessionConfiguration()
        let defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders
        configuration.HTTPAdditionalHeaders = defaultHeaders
        configuration.requestCachePolicy = .UseProtocolCachePolicy
        configuration.URLCache = cache
    }
}