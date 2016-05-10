//
//  jsonGetter.swift
//  Tearooms
//
//  Created by Jiří Hroník on 24/03/16.
//  Copyright © 2016 Jiří Hroník. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class jsonGetter {
    let url: String
    var json: JSON?
    
    init (url: String) {
        self.url = url
    }
    
    func getJSON () -> JSON? {
        Alamofire.request(.GET, self.url).responseJSON {
            response in
            if let json = response.result.value {
                self.json = JSON(json)
            }
        }
        
        return self.json
    }
}
