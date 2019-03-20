import Vapor
import FluentMySQL
import Foundation

fileprivate let paramError = "请求参数错误"
fileprivate let secretKeyError = "APP鉴权错误"

final class UserController{
    ///用户注册
    func register(req:Request) throws -> Future<ResponseModel<UserRegistInfo>>{
        return try req.content.decode(RequestModel<UserRegistInfo>.self).flatMap(){ requestBody in 
            return try SercretKey.JudgeSercretKey(sercreKey:requestBody.sercretkey,req:req).flatMap(){result in 
                if !result{
                    return req.eventLoop.newSucceededFuture(result:ResponseModel<UserRegistInfo>(status:-3,message:secretKeyError,data:nil))
                }
                if requestBody.data == nil{
                    return req.eventLoop.newSucceededFuture(result:ResponseModel<UserRegistInfo>(status:-2,message:paramError,data:nil))
                }
                return try requestBody.data!.check(req:req).flatMap(){checkresult in
                    if checkresult == .ok{
                        requestBody.data!.password = try encryptPassword(password:requestBody.data!.password!)
                        return requestBody.data!.save(on:req).map(){user in
                            return ResponseModel<UserRegistInfo>(status:0,message:"注册成功",data:nil)
                        }
                    }else{
                        return req.eventLoop.newSucceededFuture(result:ResponseModel<UserRegistInfo>(status:-1,message:checkresult.rawValue,data:nil))
                    }
                }
            }
        }
    }
    
    
    ///获取验证码
    func getVerifyCode(req:Request) throws -> Future<ResponseModel<String>>{
        return try req.content.decode(RequestModel<GBoxEmail>.self).flatMap(){requestBody in
            return try SercretKey.JudgeSercretKey(sercreKey: requestBody.sercretkey, req: req).flatMap(){result in
                if !result{
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status:-3,message:secretKeyError,data:nil))
                }
                guard let email = requestBody.data else{
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<String>(status:-2,message:paramError,data:nil))
                }
                return GBoxEmail.sendEmialCode(req: req, email: email.email).map(){sendEmailResult in
                    if sendEmailResult{
                        return ResponseModel<String>(status: 0, message: "发送验证码成功", data: nil)
                    }
                    return ResponseModel<String>(status: -1, message: "发送验证码失败", data: nil)
                }
            }
        }
    }
    
    
    ///用户登录
    func login(req:Request) throws -> Future<ResponseModel<AccessToken>>{
        return try req.content.decode(RequestModel<UserLoginInfo>.self).flatMap(){requestBody in
            return try SercretKey.JudgeSercretKey( sercreKey: requestBody.sercretkey, req: req).flatMap(){ result in
                if !result{
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<AccessToken>(status:-3,message:secretKeyError,data:nil))
                }
                guard var user = requestBody.data else{
                    return req.eventLoop.newSucceededFuture(result: ResponseModel<AccessToken>(status: -2, message: paramError, data: nil))
                }
                //检查账户密码是否存在
                user.password = try encryptPassword(password: user.password)
                return  UserRegistInfo.query(on: req).filter(\.username == user.username).filter(\.password == user.password).first().map(){ userRegistInfo in
                    if userRegistInfo == nil{
                        return ResponseModel<AccessToken>(status: -1, message: "用户名或密码错误", data: nil)
                    }
                    let accessToken = AccessToken.login(user: user)
                    return ResponseModel<AccessToken>(status: 0, message: "登录成功", data: accessToken)
                }
            }
        }
    }
}
