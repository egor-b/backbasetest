//
//  City.swift
//  backbasetest
//
//  Created by Egor Bryzgalov on 2/28/19.
//  Copyright © 2019 Egor Bryzgalov. All rights reserved.
//

import Foundation

struct City {
    var name: String
    var country: String
    var lon: Double
    var lat: Double
    var id: Int
    init(_name: String?, _country: String?, _lon: Double?, _lat: Double?, _id: Int?) {
        self.name = _name ?? ""
        self.country = _country ?? ""
        self.lon = _lon ?? 0
        self.lat = _lat ?? 0
        self.id = _id ?? 0
    }
}
