//
//  DownloadManager.swift
//  DownloadManager
//
//  Created by Saeedeh on 06/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
class DownloadManager:NSObject{
    
    private  var onGoingRequests=[Request]()
    private  var cachedObjects=[DownloadedObject]()
    
    private  var usedChacheSize:Int=0
    private  var maximumCacheSize:UInt=DownloadManagerConstants.Chache.maxChacheSize

    typealias CancellationToken = Int
    
    var downloadDelay:UInt32=0
    
    private var session: URLSession = URLSession()
    static let shared: DownloadManager = DownloadManager()
    
    private override init(){
        
        super.init()
        let sessionConfiguration = URLSessionConfiguration.default
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
    }
    
    func download(url:URL,complationHandler:@escaping((_ data:Data?,_ error:Error?) -> Void))->CancellationToken {
        
        // get chached version if any
        if let cachedObject=getChachedVersion(url: url.absoluteString)
        {
            complationHandler(cachedObject.data,nil)
            let cancellationToken=0
            return cancellationToken
        }
        
        // this object does not exsit in the cache, need to be download
        // check if there is any ongoing request for this url
        if let onGoingRequest=getOnGoingRequest(url:url.absoluteString) {
            
            let cancellationToken=onGoingRequest.addComplationHandler(complationHandler: complationHandler)
            return cancellationToken
        }
        
        // there is no ongoing downolad for this url( it is the first request for this url), create a new request for this url
        let newRequest=Request(url: url.absoluteString,complationHandler:complationHandler)
        onGoingRequests.append(newRequest)
        let cancellationToken=1
        
        // go for download
        let task=self.session.downloadTask(with: url)
        newRequest.task=task
        
        task.resume()
        
        return cancellationToken
        
    }
    
    private func addToCache(downloadedObject:DownloadedObject){
        
        let objectSize=downloadedObject.getSize()
        
        // in case the chache does not reached to its maximum size: add the new object to the chache:
        if ((self.usedChacheSize+objectSize)<self.maximumCacheSize){
            
            self.cachedObjects.append(downloadedObject)
            self.usedChacheSize+=objectSize
            
        }
        else{
            /* in case the chache hits its maximum size: check if the new downloaded object is being requested more than
             the last object saved in the chache, remove the last object from chache and add the new object instead*/
            
            if let lastCachedObject=self.cachedObjects.last{
                
                if(lastCachedObject.requestedTime<downloadedObject.requestedTime){
                    
                    self.cachedObjects.removeLast(1)
                    self.cachedObjects.append(downloadedObject)
                    self.usedChacheSize+=objectSize
                }
                
            }
        }
        //sort array based on totalRequestsNumber so that the last object in the cache reperesent the least frequency requested object
        self.cachedObjects.sort(by: {$0.requestedTime>$1.requestedTime})
    }
    
    
    func getChachedVersion(url:String) -> DownloadedObject?
    {
      
        if let index = self.cachedObjects.index(where: { $0.url == url }) {
            
            print ("has cache version")
            self.cachedObjects[index].requestedTime=Date()
            return self.cachedObjects[index]
            
        }
        return nil
    }
    
    func getOnGoingRequest(url:String)->Request?{
        
        if let index=onGoingRequests.index(where: { $0.url == url }) {
            
            return onGoingRequests[index]
        }
        
        return nil
    }
    
    func cancel(url:String,cancellationToken:CancellationToken){
        
        if(cancellationToken==0){
            return
        }
        let results = onGoingRequests.filter({ $0.url == url })
        if results.count > 0 {
            
            let toBeCancelRequest=results[0]
            toBeCancelRequest.numberOfRequests-=1
            _=toBeCancelRequest.complationHandlers.remove(at: (cancellationToken-1))
            
            // check if there is no other request for this url cancel the download task
            if(toBeCancelRequest.numberOfRequests==0){
                // cancel the download task
                toBeCancelRequest.task!.cancel()
                // remove it from onGoingRequest list
                if let index = onGoingRequests.index(where: { $0 === toBeCancelRequest }) {
                    
                    onGoingRequests.remove(at: index)
                }
            }
        }
    }
    
    func getMaximumCacheSize()->UInt{
        
        return maximumCacheSize
    }
    
    func setMaximumCacheSize(newSize:UInt){
        
        if(newSize>self.maximumCacheSize){
            
            self.maximumCacheSize=newSize
        }
        else{
            
            while usedChacheSize>newSize && cachedObjects.count>0{

                removeObjectFromCache()
            }
            
            self.maximumCacheSize=newSize
        }
        
    }
    
    private func removeObjectFromCache(){
        
        //The last object in the cache reperesent the least frequency requested object
        self.usedChacheSize-=(cachedObjects.last?.data.count)!
        cachedObjects.removeLast()
        
    }
}

// MARK:- Delegates for URLSession
extension DownloadManager : URLSessionDelegate, URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession,downloadTask: URLSessionDownloadTask,didFinishDownloadingTo location: URL) {

        
        if (self.downloadDelay>0){
            
            sleep(self.downloadDelay)
        }
        
        let url = (downloadTask.originalRequest?.url?.absoluteString)!
        
        if let index = self.onGoingRequests.index(where: { $0.url == url}){
            
            let request=self.onGoingRequests[index]
            
            if let httpResponse = downloadTask.response as? HTTPURLResponse {
                
                if (200...299).contains(httpResponse.statusCode)==false {
                    
                    let error = NSError(domain: DownloadManagerConstants.DomainError.httpError, code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)])
                    
                    // inform all controllers about the error
                    DispatchQueue.main.async{
                        
                        for completion in request.complationHandlers
                        {
                            completion(nil,error)
                        }
                        // remove request from on going requests
                        if let index = self.onGoingRequests.index(where: { $0.url == url}){
                            self.onGoingRequests.remove(at: index)
                        }
                    }
                }
                else{
                    
                    do {
                        
                        print ("data received")
                        let data = try Data(contentsOf: location)
                        DispatchQueue.main.async{
                            
                            // add object to cache
                            let downloadedObject=DownloadedObject(url:url ,data:data)
                            self.addToCache(downloadedObject: downloadedObject)
                            // inform all controllers about the data
                            
                            for completion in request.complationHandlers
                            {
                                completion(data,nil)
                            }
                            // remove request from on going requests
                            if let index = self.onGoingRequests.index(where: { $0.url == url}){
                                self.onGoingRequests.remove(at: index)
                            }
                        }
                    }
                    catch (let error) {
                        
                        print ("file error")
                        // file error
                        let error = NSError(domain: DownloadManagerConstants.DomainError.fileError, code: 0, userInfo: [NSLocalizedDescriptionKey : error.localizedDescription])
                        
                        // inform all controllers about the error
                        DispatchQueue.main.async{
                            
                            for completion in request.complationHandlers
                            {
                                completion(nil,error)
                            }
                            // remove request from on going requests
                            if let index = self.onGoingRequests.index(where: { $0.url == url}){
                                self.onGoingRequests.remove(at: index)
                            }
                        }
                    }
                }
            }
                
            else{
                
                print ("server error")
                let error = NSError(domain: DownloadManagerConstants.DomainError.serverError, code: 0, userInfo: [NSLocalizedDescriptionKey : DownloadManagerConstants.ErrorMessage.serverError])
                
                // inform all controllers about the error
                DispatchQueue.main.async{
                    
                    for completion in request.complationHandlers
                    {
                        completion(nil,error)
                    }
                    // remove request from on going requests
                    if let index = self.onGoingRequests.index(where: { $0.url == url}){
                        self.onGoingRequests.remove(at: index)
                    }
                }
            }
        }
    }
    
    public func urlSession(_ session: URLSession,downloadTask: URLSessionDownloadTask,didWriteData bytesWritten: Int64,totalBytesWritten: Int64,totalBytesExpectedToWrite: Int64) {
        
      // to be impelemnt to call a progressHandler
    }
    
    public func urlSession(_ session: URLSession,task: URLSessionTask,didCompleteWithError error: Error?) {
        

        
        if let error = error {
            let downloadTask = task as! URLSessionDownloadTask
            let url = (downloadTask.originalRequest?.url?.absoluteString)!
            
            if let index = self.onGoingRequests.index(where: { $0.url == url}){
                let request=onGoingRequests[index]
                
                // inform all controllers about the error
                DispatchQueue.main.async{
                    
                    for completion in request.complationHandlers
                    {
                        completion(nil,error)
                    }
                    // remove request from on going requests
                    self.onGoingRequests.remove(at: index)
                }
            }
        }
    }
    
}


// MARK:- Extension for UnitTests
extension DownloadManager{
    
    func clearCache(){
        
        self.cachedObjects.removeAll()
        self.usedChacheSize=0
        
    }
    func clearOnGoingRequests(){
        
        onGoingRequests.removeAll()
    }
    func getUsedCacheSize()->Int{
        
        return usedChacheSize
    }
    
    func getNumberOfCachedObjects()->Int{
        
        return cachedObjects.count
    }
    
    func getNumberOfOngoingRequests(url:String)->Int{
        
        if let index = onGoingRequests.index(where: { $0.url == url }) {
            
            return onGoingRequests[index].numberOfRequests
        }
        return 0
    }
    
    func turnOnDownloadDelay(delay:UInt32){
        
        downloadDelay=delay
    }
    func turnOffDownloadDelay(){
        
        downloadDelay=0
        
    }
}
