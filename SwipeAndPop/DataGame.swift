//
//  Data.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 20.10.2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//

import UIKit

class DataGame: CustomStringConvertible {
    let name: String
    let ownerID: String
    let ownerName: String
//    let ownerLevel: String
//    let ownerScore: String
//    let ownerTotalScore: String
//
    init(name:String, ownerID:String, ownerName: String) {
        self.name = name
        self.ownerID = ownerID
        self.ownerName = ownerName
//        self.ownerLevel = ownerLevel
//        self.ownerScore = ownerScore
//        self.ownerTotalScore = ownerTotalScore
    }
    
    init(json: [String: Any]) {
        self.name = json["Name"] as! String
        self.ownerID = json["OwnerID"] as! String
        self.ownerName = json["OwnerName"] as! String
//        self.ownerLevel = json["OwnerLevel"] as! String
//        self.ownerScore = json["OwnerScore"] as! String
//        self.ownerTotalScore = json["OwnerTotalScore"] as! String

    }
    var description: String{
        return "Data Name: \(name)\n Email: \(ownerName) \n ID: \(ownerID)"
    }
    
    //Computed Property
    var json:[String: Any]{
        return [
            "Name": name,
            "OwnerID": ownerID,
            "OwnerName": ownerName,
            //"OwnerLevel": ownerLevel,
            //"OwnerScore": ownerScore,
            //"OwnerTotalScore": ownerTotalScore
        ]
    }
}

