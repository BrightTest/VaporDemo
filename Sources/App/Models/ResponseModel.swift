//
//  ResponseModel.swift
//  App
//
//  Created by GZSD on 2019/3/19.
//

import Foundation
import Vapor

struct ResponseModel<T>:Content where T:Codable{
    var status:Int
    var message:String
    var data:T?
}
