//
//  UserRegisterInfo.swift
//  App
//
//  Created by GZSD on 2019/3/19.
//

import Foundation
import Vapor
import FluentMySQL

enum UserRegisterEnum:String{
    case ok = "注册成功"
    case verifycodeError = "验证码错误"
    case useralreadyExit = "用户名已被注册"
    case passwordisEmpty = "密码不能为空"
    case emailisEmpty = "邮箱不能为空"
    case verifycodeisEmpty = "验证码不能为空"
}

struct UserRegisterInfo:MySQLModel{
    static var entity = "user_regist_info"
    
    var id:Int?
    var username:String
    var password:String?
    var email:String?
    var verifycode:String?
}

extension UserRegisterInfo{
    func check(req:Request) throws ->Future<UserRegisterEnum>{
        ///检查数据完整性
        guard self.password != nil else{
            return req.eventLoop.newSucceededFuture(result: .passwordisEmpty)
        }
        guard let email = self.email else{
            return req.eventLoop.newSucceededFuture(result: .emailisEmpty)
        }
        guard let verifyCode = self.verifycode else{
            return req.eventLoop.newSucceededFuture(result: .verifycodeisEmpty)
        }
        //检查验证是否正确
        let userMail = GBoxEmail(email:email,verifycode:verifyCode)
        if !userMail.checkVerifyCode(){
            return req.eventLoop.newSucceededFuture(result: .verifycodeError)
        }
        //检查是否注册过
        return try UserRegisterInfo.query(on: req).filter(\UserRegisterInfo.username == self.username).first().map({ user  in
            if user != nil{
                return .useralreadyExit
            }
            return .ok
        })
    }
}

extension UserRegisterInfo:Migration{}

extension UserRegisterInfo:Content{}
