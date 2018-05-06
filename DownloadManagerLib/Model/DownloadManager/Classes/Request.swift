//
//  Request.swift
//  DownloadManager
//
//  Created by Saeedeh on 06/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation

class Request{
    
    let url:String
    var task:URLSessionDownloadTask?
    var numberOfRequests:Int
    var complationHandlers:[((_ data:Data?,_ error:Error?) -> Void)]=[]
    
    init(url:String,complationHandler:@escaping ((_ data:Data?,_ error:Error?) -> Void)) {
        self.url=url
        numberOfRequests=1
        complationHandlers.append(complationHandler)
    }
    func addComplationHandler(complationHandler:@escaping ((_ data:Data?,_ error:Error?) -> Void))->Int{
        
        complationHandlers.append(complationHandler)
        numberOfRequests+=1
        return complationHandlers.count
    }
}
