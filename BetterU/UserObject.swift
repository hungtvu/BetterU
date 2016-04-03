//
//  UserObject.swift
//  BetterU
//
//  Created by Hung Vu on 4/2/16.
//  Copyright © 2016 BetterU LLC. All rights reserved.
//

import SwiftyJSON

class UserObject {
    var password: String!
    var username: String!
    
    required init(json: JSON) {
        username = json["username"].stringValue
        password = json["password"].stringValue
    }
}