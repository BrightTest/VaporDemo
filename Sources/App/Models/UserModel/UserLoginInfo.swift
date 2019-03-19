//
//  UserLoginInfo.swift
//  App
//
//  Created by GZSD on 2019/3/19.
//

import Foundation
import Vapor
import FluentMySQL

struct UserLoginInfo:Content{
    var username:String
    var password:String
}
