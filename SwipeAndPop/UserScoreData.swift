//
//  UserScoreData.swift
//  SwipeAndPop
//
//  Created by Asher Elgar on 25/10/2017.
//  Copyright © 2017 Asher Elgar. All rights reserved.
//

import UIKit

class UserScoreData: CustomStringConvertible {
    
    let ownerID: String
    let ownerLevel: String
    let ownerScore: String
    let ownerTotalScore: String
    
    init(ownerID:String, ownerLevel: String, ownerScore: String, ownerTotalScore: String) {
        self.ownerID = ownerID
        self.ownerLevel = ownerLevel
        self.ownerScore = ownerScore
        self.ownerTotalScore = ownerTotalScore
    }
    
    init(json: [String: Any]) {
        
        self.ownerID = json["OwnerID"] as! String
        
        self.ownerLevel = json["OwnerLevel"] as! String
        self.ownerScore = json["OwnerScore"] as! String
        self.ownerTotalScore = json["OwnerTotalScore"] as! String
        
    }
    var description: String{
        return "## UserScoreData ID: \(ownerID) \n Level: \(ownerLevel) \n Score: \(ownerScore) \n OwnerTotalScore: \(ownerTotalScore)"
    }
    
    //Computed Property
    var json:[String: Any]{
        return [
            "OwnerID": ownerID,
            "OwnerLevel": ownerLevel,
            "OwnerScore": ownerScore,
            "OwnerTotalScore": ownerTotalScore
        ]
    }
}


