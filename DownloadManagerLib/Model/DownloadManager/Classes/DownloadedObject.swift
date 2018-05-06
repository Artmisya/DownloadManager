//
//  DownloadedObject.swift
//  DownloadManager
//
//  Created by Saeedeh on 06/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
class DownloadedObject:Equatable{
    
    let url:String
    var data:Data
    var requestedTime:Date

    init(url:String,data:Data) {
        
        self.url=url
        
        self.requestedTime=Date()
        self.data=data
    }
    
    func getSize()->Int{
        
        return self.data.count
        
    }
    // two object of ObjectToBeDownload class are equal if their url are the same
    static func ==(firstObject: DownloadedObject, secondObject: DownloadedObject) -> Bool {
        guard firstObject.url == secondObject.url else {
            return true
        }
        
        return false
    }
}


