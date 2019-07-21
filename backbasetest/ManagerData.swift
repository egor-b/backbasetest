//
//  ManagerData.swift
//  backbasetest
//
//  Created by Egor Bryzgalov on 2/28/19.
//  Copyright © 2019 Egor Bryzgalov. All rights reserved.
//

import Foundation

class ManagerData {
    
    private static var sharedManger: ManagerData?
    
    private init() {}
    
    static func shared() -> ManagerData {
        if sharedManger == nil {
            sharedManger = ManagerData()
        }
        return sharedManger!
    }
    
    var syncQueue = DispatchQueue(label: "com.test.write", attributes: .concurrent)
    
    func readJSON(completion:@escaping([City]?, Float) -> Swift.Void) {
        var city = [City]()
        if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
            DispatchQueue.global().async {
                do {
                    let fileUrl = URL(fileURLWithPath: path)
                    let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                    var jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [[String:Any]]
                    for (index, _) in jsonResult.enumerated() {
                        DispatchQueue.global().async {
                            self.syncQueue.async(flags: .barrier) {
                                city.append(City(_name: jsonResult[index]["name"] as? String,
                                                 _country: jsonResult[index]["country"] as? String,
                                                 _lon: (jsonResult[index]["coord"] as! [String:Any])["lon"] as? Double,
                                                 _lat: (jsonResult[index]["coord"] as! [String:Any])["lat"] as? Double,
                                                 _id: jsonResult[index]["_id"] as? Int))
                                city.sort(by: {$0.name < $1.name})
//                                print(index)
                                completion(city, Float((100*(index+1))/jsonResult.count)/100)
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
