//
//  GNewsBoxTools.swift
//  App
//
//  Created by GZSD on 2019/3/19.
//

import Foundation
import Crypto

func encryptPassword(password:String) throws -> String{
    return try SHA1.hash(password).hexEncodedString()
}

func saveFileTo(data:File,filepath:String) throws {
    try data.data.write(to: URL(fileURLWithPath: filepath + "/" + data.filename))
}
