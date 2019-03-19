//
//  AccessTokenManager.swift
//  App
//
//  Created by GZSD on 2019/3/19.
//

import Foundation
import Vapor
import Crypto

enum AccessTokenStatusEnum:String{
    case ok = "成功"
    case timeout = "过期"
    case unlogin = "未登录"
}

///用户accessToken缓存
fileprivate var accessTokenCache = Dictionary<String,AccessToken>()
fileprivate var usernameCache = Dictionary<String,String>()


final class AccessToken:Content{
    var username:String
    var accessToken:String
    var createTime:Int
    var expireIn:Int
    
    init(username:String,createTime:Int = Int(Date().timeIntervalSince1970),expireIn:Int = 24 * 60 * 60) {
        self.username = username
        self.createTime = createTime
        self.expireIn = expireIn
        do{
            self.accessToken = try MD5.hash(username + String(createTime)).hexEncodedString()
        }catch{
            self.accessToken = username + String(createTime)
        }
    }
}

extension AccessToken{
    ///检查是否过期
    fileprivate func checkTimeOut() -> Bool{
        let newInterval = Int(Date().timeIntervalSince1970)
        if newInterval > createTime + expireIn{
            return true
        }else{
            return false
        }
    }
    
    ///检查accessToken状态
    public static func checkAccessToken(accessToken:String?) -> AccessTokenStatusEnum{
        guard let accessToken = accessToken else{
            return .unlogin
        }
        
        guard let tokenStruct = accessTokenCache[accessToken] else{
            return .unlogin
        }
        //计算是否超时
        if tokenStruct.checkTimeOut(){
            return .timeout
        }
        return .ok
    }
    
    ///登录操作
    public static func login(user:UserLoginInfo) -> AccessToken{
        let accessTokenStruct = AccessToken(username: user.username)
        
        //清空之前的登录信息
        let oldaccessToken = usernameCache[user.username]
        if oldaccessToken != nil{
            accessTokenCache[oldaccessToken!] = nil
            usernameCache[user.username] = nil
        }
        
        //缓存username to accessToken
        usernameCache[user.username] = accessTokenStruct.accessToken
        //缓存accessToken struct
        accessTokenCache[accessTokenStruct.accessToken] = accessTokenStruct
        
        return accessTokenStruct
        
    }
    
    ///注销操作
    public static func logout(accessToken:String) -> Bool{
        guard let username = accessTokenCache[accessToken]?.username else{
            return false
        }
        
        usernameCache[username] = nil
        accessTokenCache[accessToken] = nil
        return true
    }
    
    ///刷新操作
    public static func refreshAccessToken(accessToken:String) -> AccessToken?{
        guard let username = accessTokenCache[accessToken]?.username else{
            return nil
        }
        
        //清除缓存
        accessTokenCache[accessToken] = nil
        let newAccessToken = AccessToken(username: username)
        
        usernameCache[username] = newAccessToken.accessToken
        accessTokenCache[newAccessToken.accessToken] = newAccessToken
        return newAccessToken
    }
    
    ///获取accessToken对应用户信息
    public static func getUserNameByAccessToken(accessToken:String) -> String?{
        return accessTokenCache[accessToken]?.username
    }
}
