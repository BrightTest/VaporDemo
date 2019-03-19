//
//  RequestModel.swift
//  App
//
//  Created by GZSD on 2019/3/19.
//

import Foundation
import Vapor
import FluentMySQL
import Crypto

///保证接口安全
struct SercretKey:MySQLModel{
    var id:Int?
    var sercretkey:String
}

extension SercretKey:Migration{}
extension SercretKey{
    //检查是否授权
    static func JudgeSercretKey(sercreKey:String,req:Request) throws -> Future<Bool>{
        return try SercretKey.query(on:req).filter(\.sercretkey == sercrekey).first().map(){ result in
            if result == nil{
                return false
            }
            return true
        }
    }
}
