import Vapor
import FluentMySQL
import Foundation

fileprivate let paramError = "请求参数错误"
fileprivate let secretKeyError = "APP鉴权错误"

final class UserController{
    ///用户注册
    func register(req:Request) throws -> Future<ResponseModel<UserRegistInfo>>{
        return try req.content.decode(RequestModel<UserRegistInfo>.self).flatMap(){ requestBody in 
            return try SercretKey.JudgeSercretKey(sercreKey:requestBody.sercreKey,req:req).flatMap(){result in 
                if !result{
                    return req.eventLoop.newSuccessdedFuture(result:ResponseModel<UserRegistInfo>(status:-3,message:secretKeyError,data:nil))
                }
                if requestBody.data == nil{
                    return req.eventLoop.newSuccessdedFuture(result:ResponseModel<UserRegistInfo>(status:-2,message:paramError,data:nil))
                }
                return try requestBody.data!.check(req:req).flatMap(){checkresult in
                    if checkresult == .ok{
                        requestBody.data!.password = try encryptPassword(password:requestBody.data!.password!)
                        return requestBody.data!.save(on:req).map(){user in
                            return ResponseModel<UserRegistInfo>(status:0,message:"注册成功",data:nil)
                        }
                    }else{
                        return req.eventLoop.newSuccessdedFuture(result:ResponseModel<UserRegistInfo>(status:-1,message:checkresult.rawValue,data:nil))
                    }
                }
            }
        }
    }
}
