//
//  VerifyEmail.swift
//  App
//
//  Created by GZSD on 2019/3/19.
//

import Foundation
import Vapor
import SwiftSMTP

struct GBoxEmail:Content{
    var email:String
    var verifycode:String?
}

fileprivate var emailDic = Dictionary<String,String>()

fileprivate let smtp = SMTP(hostname: "smtp.163.com", email: "brighttest@163.com", password: "brighttest123")

fileprivate let GNewsBoxMailAddress =  Mail.User(name: "新闻盒子", email: "brighttest@163.com")

extension GBoxEmail{
    func checkVerifyCode() -> Bool{
        guard let verifyCode = emailDic[self.email] else{
            return false
        }
        guard let customVerifyCode = self.verifycode else{
            return false
        }
        if verifyCode == customVerifyCode{
            emailDic[self.email] = nil
            return true
        }
        return false
    }
}


extension GBoxEmail{
    static func sendEmialCode(req:Request,email:String) -> Future<Bool>{
        var verifyCode = emailDic[email]
        
        if verifyCode == nil{
            verifyCode =  RandomString.sharedInstance.getRandomStringOfLength(length: 4)
        }
        
        let userMail = Mail.User(email: email)
        let mail = Mail(from: GNewsBoxMailAddress, to: [userMail],  subject: "欢迎注册新闻盒子", text: "您本次的验证码为:\(verifyCode!)")
        
        let result = req.eventLoop.newPromise(Bool.self)
        smtp.send(mail){error in
            if let error = error {
                print(error)
                result.succeed(result: false)
            }else{
                emailDic[email] = verifyCode!
                result.succeed(result: true)
            }
        }
        return result.futureResult
    }
}

//随机字符串生成
class RandomString{
    var str = "1234567890"
    static let sharedInstance = RandomString()
    private init(){}
    
    func getRandomStringOfLength(length:Int)->String{
        var ranstr = ""
        for _ in 0...length{
            let index = Int(arc4random_uniform(UInt32(str.count)))
            ranstr.append(str[str.index(str.startIndex, offsetBy: index)])
        }
        return ranstr
    }
}
