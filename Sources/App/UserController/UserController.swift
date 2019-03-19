//
//  UserController.swift
//  App
//
//  Created by GZSD on 2019/3/19.
//

import Foundation
import Vapor
import FluentMySQL

fileprivate let paramError = "请求参数错误"
fileprivate let secretKeyError = "APP鉴权错误"


final class UserController{
    ///用户注册
    func register(req:Request) throws ->Future<ResponseModel<UserRegistInfo>>{
        return try req.content.decode(RequestModel<UserRegistInfo>.self).flatMap({ (requestBody)   in
            return try SercretKey.JudgeSercretKey(sercreKey: requestBody.sercretkey, req: req).flatMap({ (result) in
                if !result{
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<UserRegistInfo>(status:-3,message:secretKeyError,data:nil))
                }
                if requestBody.data == nil{
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<UserRegistInfo>(status:-2,message:paramError,data:nil))
                }
                return try requestBody.data!.check(req: req).flatMap({ checkResult  in
                    if checkResult == .ok{
                        requestBody.data?.password = try encryptPassword(password: requestBody.data!.password!)
                        return requestBody.data!.save(on: req).map({ (user)   in
                            return ResponseModel<UserRegistInfo>(status:0,message:"注册成功 ",data:nil)
                        })
                    }else{
                        return req.eventLoop.newSucceededFuture(result: ResponseModel<UserRegistInfo>(status: -1, message: checkResult.rawValue, data: nil))
                    }
                })
            })
        })
    }
}
