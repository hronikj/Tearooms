//
//  Tearoom.swift
//  Tearooms
//
//  Created by Jiří Hroník on 24/03/16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import Foundation

class Tearoom {    
    let data: [fieldsDictionaryKeysForAPI: AnyObject]
    
    internal enum fieldsDictionaryKeysForAPI {
        // strings
        case name
        case city
        case locationLongitude
        case locationLatitude
        case id
        case street
        case zipcode
        
        // bools
        case OpensInMonday
        case OpensInTuesday
        case OpensInWednesday
        case OpensInThursday
        case OpensInFriday
        case OpensInSaturday
        case OpensInSunday
        
        // opening times
        case OpeningTimeForMonday
        case OpeningTimeForTuesday
        case OpeningTimeForWednesday
        case OpeningTimeForThursday
        case OpeningTimeForFriday
        case OpeningTimeForSaturday
        case OpeningTimeForSunday
        
        // closing times
        case ClosingTimeForMonday
        case ClosingTimeForTuesday
        case ClosingTimeForWednesday
        case ClosingTimeForThursday
        case ClosingTimeForFriday
        case ClosingTimeForSaturday
        case ClosingTimeForSunday
    }
    
    enum openingDays {
        case Monday
        case Tuesday
        case Wednesday
        case Thursday
        case Friday
        case Saturday
        case Sunday
    }
    
    enum OpeningTimesKeysForDictionary {
        case MondayOpeningTime
        case MondayClosingTime
        case TuesdayOpeningTime
        case TuesdayClosingTime
        case WednesdayOpeningTime
        case WednesdayClosingTime
        case ThursdayOpeningTime
        case ThursdayClosingTime
        case FridayOpeningTime
        case FridayClosingTime
        case SaturdayOpeningTime
        case SaturdayClosingTime
        case SundayOpeningTime
        case SundayClosingTime
    }
    
    init (data: [fieldsDictionaryKeysForAPI: AnyObject]) {
        self.data = data
    }
    
    func getOpeningTimeForDay(day: String, closing: Bool) -> NSDate? {
        switch day {
        case "Monday":
            if closing { return self.data[.ClosingTimeForMonday] as? NSDate }
            return self.data[.OpeningTimeForMonday] as? NSDate
        case "Tuesday":
            if closing { return self.data[.ClosingTimeForTuesday] as? NSDate }
            return self.data[.OpeningTimeForTuesday] as? NSDate
        case "Wednesday":
            if closing { return self.data[.ClosingTimeForWednesday] as? NSDate }
            return self.data[.OpeningTimeForWednesday] as? NSDate
        case "Thursday":
            if closing { return self.data[.ClosingTimeForThursday] as? NSDate }
            return self.data[.OpeningTimeForThursday] as? NSDate
        case "Friday":
            if closing { return self.data[.ClosingTimeForFriday] as? NSDate }
            return self.data[.OpeningTimeForFriday] as? NSDate
        case "Saturday":
            if closing { return self.data[.ClosingTimeForSaturday] as? NSDate }
            return self.data[.OpeningTimeForSaturday] as? NSDate
        case "Sunday":
            if closing { return self.data[.ClosingTimeForSunday] as? NSDate }
            return self.data[.OpeningTimeForSunday] as? NSDate
        default:
            return nil
        }
    }
    
    func isOpenNow(tearoom: Tearoom) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        var currentDate = NSDate()
        let timeComponentsForCurrentDate = calendar.components([.Hour, .Minute], fromDate: currentDate)
        currentDate = calendar.dateFromComponents(timeComponentsForCurrentDate)!
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfTheWeek = dateFormatter.stringFromDate(NSDate())
        
        if let openingDate = getOpeningTimeForDay(dayOfTheWeek, closing: false) {
            let componentsForOpeningTime = calendar.components([.Hour, .Minute], fromDate: openingDate)
            let openingTime = calendar.dateFromComponents(componentsForOpeningTime)
            
            if let closingDate = getOpeningTimeForDay(dayOfTheWeek, closing: true) {
                let componentsForClosingTime = calendar.components([.Hour, .Minute], fromDate: closingDate)
                let closingTime = calendar.dateFromComponents(componentsForClosingTime)
                
                var compareResult = openingTime?.compare(currentDate)
                if compareResult == NSComparisonResult.OrderedAscending {
                    // from should be later than current date
                    compareResult = closingTime?.compare(currentDate)
                    if compareResult == NSComparisonResult.OrderedDescending {
                        // current time should be before closing time
                        return true
                    }
                }
            } else {
                print("Couldn't get closing time for given day!")
            }
            
        } else {
            print("Couldn't get opening time for given day!")
        }
    
        return false
    }
}
