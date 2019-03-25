//
//  UserInfo.swift
//  App
//
//  Created by GZSD on 2019/3/19.
//

import Foundation
import Vapor
import FluentMySQL

struct UserInfo:MySQLModel{
    static var entity = "user_info"
    
    var id: Int?
    var username:String?
    var nickname:String?
    var headpic:String?
    var sex:String?
    var note:String?
}

extension UserInfo{
    mutating func megreUser(orginUser:UserInfo) -> UserInfo{
        if nil == self.id{
            self.id = orginUser.id
        }
        if nil == self.username{
            self.username = orginUser.username
        }
        if nil == self.nickname{
            self.nickname = orginUser.nickname
        }
        if nil == self.headpic{
            self.headpic = orginUser.headpic
        }
        if nil == self.sex{
            self.sex = orginUser.sex
        }
        if nil == self.note{
            self.note = orginUser.note
        }
        return self
    }
}

extension UserInfo:Content{}

extension UserInfo:Migration{}

extension UserInfo:Parameter{}
