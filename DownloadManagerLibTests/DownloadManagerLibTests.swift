//
//  DownloadManagerLibTests.swift
//  DownloadManagerLibTests
//
//  Created by Saeedeh on 07/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import XCTest
@testable import DownloadManagerLib

class DownloadManagerLibTests: XCTestCase {
    
    var downloadManagerUnderTest: DownloadManager!
    
    let urlStringUnderTest:String="https://www.visitcopenhagen.com/sites/default/files/styles/top_ten_references_large/public/asp/visitcopenhagen/Visit-sites/1080x1080/Tivoli/tivoli_efteraar_01_thomas_hoyrup_christensen.jpg?itok=4nsDuosx"
    let secondUrlStringUnderTest:String="https://lh6.googleusercontent.com/proxy/kXtKXrpoi8Xw3LXMzrbd9Wh4IP5n4qZ4spl5fbQLaaP1sF40l3810sLVwEifpvmEYLDnG6xVDDVk-rkB5fMupifc4vlkBy4hRlFpVy6RIRXP_3q6rh7qGX6vDP-CK7Z3iwHL0oUznh64rtgM_dy_I8p-KHztLg=w100-h134-n-k-no"
    let thirdUrlStringUnderTest="https://lh5.googleusercontent.com/-gx8W0lax8Ts/Wi8jstP6AVI/AAAAAAAAdSE/hYj9GMf6VZwO51MwcRXHJC4gCQJfXMuTwCLIBGAYYCw/w100-h134-n-k-no/"
    let moreRecentUrlStringUnderTest="https://lh5.googleusercontent.com/-gx8W0lax8Ts/Wi8jstP6AVI/AAAAAAAAdSE/hYj9GMf6VZwO51MwcRXHJC4gCQJfXMuTwCLIBGAYYCw/w100-h134-n-k-no/"
    let lessRecentUrlStringUnderTest="https://lh6.googleusercontent.com/proxy/kXtKXrpoi8Xw3LXMzrbd9Wh4IP5n4qZ4spl5fbQLaaP1sF40l3810sLVwEifpvmEYLDnG6xVDDVk-rkB5fMupifc4vlkBy4hRlFpVy6RIRXP_3q6rh7qGX6vDP-CK7Z3iwHL0oUznh64rtgM_dy_I8p-KHztLg=w100-h134-n-k-no"
    let theMostRecentUrlStringUnderTest="https://www.visitcopenhagen.com/sites/default/files/styles/top_ten_references_large/public/asp/visitcopenhagen/Visit-sites/1080x1080/Tivoli/tivoli_efteraar_01_thomas_hoyrup_christensen.jpg?itok=4nsDuosx"
    let doesnotExsitUrlStringUnderTest="https://www.visitcopenhagen.com/SourceDoesnotExsit.jpg"
    
    
    override func setUp() {
        super.setUp()
        
        downloadManagerUnderTest=DownloadManager.shared
        downloadManagerUnderTest.turnOnDownloadDelay(delay:3)
    }
    
    override func tearDown() {
        
        downloadManagerUnderTest=nil
        super.tearDown()
    }
    
    func testDownloadManager(){
        
        let e = expectation(description: "complationHandler handler invoked")
        let url=URL(string:urlStringUnderTest)!
        
        downloadManagerUnderTest.setMaximumCacheSize(newSize:DownloadManagerConstants.Chache.maxChacheSize)
        let maxChacheSize=downloadManagerUnderTest.getMaximumCacheSize()
        
        // first clear cache
        downloadManagerUnderTest.clearCache()
        XCTAssertTrue(0==downloadManagerUnderTest.getUsedCacheSize())
        
        
        _=self.downloadManagerUnderTest.download(url:url ,complationHandler: { (data,error) in
            
            let cacheSize=self.downloadManagerUnderTest.getUsedCacheSize()
            let NoOfcachedObjects=self.downloadManagerUnderTest.getNumberOfCachedObjects()
            
            if let result=data{
                //successfully get data from API
                XCTAssertNotNil(data, "got .success but data has not been initialized!")
                
                if(maxChacheSize>=result.count){
                    
                    XCTAssertTrue(NoOfcachedObjects==1,"expected one got :\(NoOfcachedObjects)")
                    XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "expected data but got nil, Data Size \(result.count), cache size \(cacheSize),NumberOfCachedObjects:\(NoOfcachedObjects)")
                    
                    XCTAssertTrue(result.count==self.downloadManagerUnderTest.getUsedCacheSize(),"cache size is not equal with downloaded data size. Data Size: \(result.count), cache size \(cacheSize),NumberOfCachedObjects:\(NoOfcachedObjects)")
                }
                else{
                    
                    XCTAssertTrue(NoOfcachedObjects==0,"expected zero got :\(NoOfcachedObjects)")
                    XCTAssertNil(self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "expected nil but got data, Data Size \(result.count), cache size \(cacheSize) ,NumberOfCachedObjects:\(NoOfcachedObjects)")
                    
                }
                e.fulfill()
            }
            else{
                
                XCTAssertNotNil(error, "Expected .success, got \(error!))")
                e.fulfill()
                
                
            }
            
        })
        
        waitForExpectations(timeout: 15.0, handler: nil)
        
    }
    
    func testDownloadManagerWithSameCuncrrentRequests(){
        
        let e = expectation(description: "complationHandler handler invoked")
        let eSecondRequest = expectation(description: "complationHandler handler invoked")
        
        let url=URL(string:secondUrlStringUnderTest)!
        
        downloadManagerUnderTest.setMaximumCacheSize(newSize: DownloadManagerConstants.Chache.maxChacheSize)
        let maxChacheSize=downloadManagerUnderTest.getMaximumCacheSize()
        
        // first clear cache
        downloadManagerUnderTest.clearCache()
        XCTAssertTrue(0==downloadManagerUnderTest.getUsedCacheSize(),"expected 0 got:\(downloadManagerUnderTest.getUsedCacheSize())")
        
        _=self.downloadManagerUnderTest.download(url:url ,complationHandler: { (data,error) in
            
            let cacheSize=self.downloadManagerUnderTest.getUsedCacheSize()
            let NoOfcachedObjects=self.downloadManagerUnderTest.getNumberOfCachedObjects()
            
            if let result=data{
                //successfully get data from API
                XCTAssertNotNil(data, "got .success but data has not been initialized!")
                
                if(maxChacheSize>=result.count){
                    
                    XCTAssertTrue(NoOfcachedObjects==1,"expected one got :\(NoOfcachedObjects)")
                    
                    XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "expected data but got nil, Data Size \(result.count), cache size \(cacheSize),NumberOfCachedObjects:\(NoOfcachedObjects)")
                    
                    XCTAssertTrue(result.count==self.downloadManagerUnderTest.getUsedCacheSize(),"cache size is not equal with downloaded data size. Data Size: \(result.count), cache size \(cacheSize),NumberOfCachedObjects:\(NoOfcachedObjects)")
                }
                else{
                    
                    XCTAssertTrue(NoOfcachedObjects==0,"expected zero got :\(NoOfcachedObjects)")
                    
                    XCTAssertNil(self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "expected nil but got data, Data Size \(result.count), cache size \(cacheSize) ,NumberOfCachedObjects:\(NoOfcachedObjects)")
                    
                }
                
            }
            else{
                
                XCTAssertNotNil(error, "Expected .success, got \(error!))")
                
            }
            
            e.fulfill()
            
        })
        
        
        
        _=self.self.downloadManagerUnderTest.download(url:url ,complationHandler: { (data,error) in
            
            let cacheSize=self.downloadManagerUnderTest.getUsedCacheSize()
            let NoOfcachedObjects=self.downloadManagerUnderTest.getNumberOfCachedObjects()
            
            if let result=data{
                
                //successfully get data from API
                XCTAssertNotNil(data, "got .success but data has not been initialized!")
                
                if(maxChacheSize>=result.count){
                    
                    XCTAssertTrue(NoOfcachedObjects==1,"expected one got :\(NoOfcachedObjects)")
                    
                    XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "expected data but got nil, Data Size \(result.count), cache size \(cacheSize),NumberOfCachedObjects:\(NoOfcachedObjects)")
                    
                    XCTAssertTrue(result.count==self.downloadManagerUnderTest.getUsedCacheSize(),"cache size is not equal with downloaded data size. Data Size: \(result.count), cache size \(cacheSize),NumberOfCachedObjects:\(NoOfcachedObjects)")
                }
                else{
                    
                    XCTAssertTrue(NoOfcachedObjects==0,"expected zero got :\(NoOfcachedObjects)")
                    
                    XCTAssertNil(self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "expected nil but got data, Data Size \(result.count), cache size \(cacheSize) ,NumberOfCachedObjects:\(NoOfcachedObjects)")
                    
                }
                
            }
                
            else{
                
                XCTAssertNotNil(error, "Expected .success, got \(error!))")
                
                
            }
            eSecondRequest.fulfill()
            
        })
        
        
        waitForExpectations(timeout: 15.0, handler: nil)
        
    }
    
    func testDownloadManagerWithSourceDoesnotExsit(){
        let e = expectation(description: "complationHandler handler invoked")
        let url=URL(string:doesnotExsitUrlStringUnderTest)!
        
        // first clear cache
        downloadManagerUnderTest.clearCache()
        // now go for  test
        
        
        _ = self.self.downloadManagerUnderTest.download(url:url ,complationHandler: { (data,error) in
            
            let NoOfcachedObjects=self.downloadManagerUnderTest.getNumberOfCachedObjects()
            
            if let result=data{
                
                XCTAssertTrue(NoOfcachedObjects==0,"expected zero got :\(NoOfcachedObjects)")
                XCTAssert(false, "Expected .failure, got : \(result))")
            }
            else{
                
                XCTAssertNotNil(error, "download was fail but no error has been returned")
                XCTAssertNil(self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "download was fail but the object was cached!")
                XCTAssert(true, "test end")
                
            }
            e.fulfill()
            
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
        
    }
    
    // test condition:  there is only one ongoing request for the the url , the task should  be cancel
    func testDownloadManagerCancel_ShouldDownload(){
        
        let e = expectation(description: "complationHandler handler invoked")
        var cancellationToken=0
        let url=URL(string:thirdUrlStringUnderTest)!
        
        // first clear cache
        downloadManagerUnderTest.clearCache()
        
        // go for  test
        cancellationToken=downloadManagerUnderTest.download(url:url ,complationHandler: { (data,error) in
            
            XCTAssert(false, "expected to not being called but got\(data,error) ")
            e.fulfill()
        })
        
        let  noOfOngoingRequestBeforeCancel=downloadManagerUnderTest.getNumberOfOngoingRequests(url:url.absoluteString)
        XCTAssertTrue(noOfOngoingRequestBeforeCancel==1,"expected one got :\(noOfOngoingRequestBeforeCancel)")
        sleep(1)
        // cancel the request
        downloadManagerUnderTest.cancel(url:url.absoluteString,cancellationToken:cancellationToken)
        let  noOfOngoingRequestAfterCancel=downloadManagerUnderTest.getNumberOfOngoingRequests(url:url.absoluteString)
        XCTAssertTrue(noOfOngoingRequestAfterCancel==0,"expected zero got :\(noOfOngoingRequestAfterCancel)")
        e.fulfill()
        
        waitForExpectations(timeout: 10.0, handler: nil)
        
    }
    
    // test condition:  there are more than one ongoing request for the  url , the task should not be canceled
    func testDownloadManagerCancel_ShouldNotDownload(){
        
        
        let e = expectation(description: "complationHandler handler invoked")
        let eSecondRequest = expectation(description: "complationHandler handler invoked")
        let url=URL(string:thirdUrlStringUnderTest)!
        
        // first clear cache
        downloadManagerUnderTest.clearCache()
        // now go for  test
        let cancellationToken=downloadManagerUnderTest.download(url:url ,complationHandler: { (data,error) in
            
            XCTAssert(false, "expected to not being called but got\(data,error) ")
            e.fulfill()
        })
        
        _=downloadManagerUnderTest.download(url:url ,complationHandler: { (data,error) in
            
            if let _=data{
                
                XCTAssert(true)
            }
            else{
                
                XCTAssert(false, "Expected .success, got : \(error!))")
                
            }
            eSecondRequest.fulfill()
        })
        
        let  noOfOngoingRequestBeforeCancel=downloadManagerUnderTest.getNumberOfOngoingRequests(url:url.absoluteString)
        XCTAssertTrue(noOfOngoingRequestBeforeCancel==2,"expected two got :\(noOfOngoingRequestBeforeCancel)")
        
        sleep(1)
        
        // first requester cancel the request
        downloadManagerUnderTest.cancel(url: url.absoluteString,cancellationToken:cancellationToken)
        
        let  noOfOngoingRequestAfterCancel=downloadManagerUnderTest.getNumberOfOngoingRequests(url:url.absoluteString)
        XCTAssertTrue(noOfOngoingRequestAfterCancel==1,"expected one got :\(noOfOngoingRequestAfterCancel)")
        e.fulfill()
        waitForExpectations(timeout: 10.0, handler: nil)
        
    }
    
    // test condition: new cacheSize < current usedcachesize
    func testDownloadManagerSetCacheSize_NewCacheSizeLesserThanCurrentUsedCacheSize(){
        
        let e = expectation(description: "complationHandler handler invoked")
        let url=URL(string:secondUrlStringUnderTest)!
        
        // first clear cache
        downloadManagerUnderTest.clearCache()
        XCTAssertTrue(0==downloadManagerUnderTest.getUsedCacheSize(),"expected 0 got:\(downloadManagerUnderTest.getUsedCacheSize())")
        
        downloadManagerUnderTest.setMaximumCacheSize(newSize: DownloadManagerConstants.Chache.maxChacheSize)
        XCTAssertTrue(DownloadManagerConstants.Chache.maxChacheSize==downloadManagerUnderTest.getMaximumCacheSize())
        
        _=self.downloadManagerUnderTest.download(url:url ,complationHandler: { (data,error) in
            
            if let result=data{
                
                let objectSize=result.count
                XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "expected data but got nil, Data Size \(objectSize), cache size \(self.downloadManagerUnderTest.getUsedCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
                
                XCTAssertTrue(objectSize==self.downloadManagerUnderTest.getUsedCacheSize(),"cache size is not equal with downloaded data size. Data Size: \(objectSize), cache size \(self.downloadManagerUnderTest.getUsedCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
                
                // set maximum cache size
                let newCacheSize=UInt(objectSize-10)
                self.downloadManagerUnderTest.setMaximumCacheSize(newSize: newCacheSize)
                XCTAssertNil(self.self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "expected nil got Data,Data Size \(objectSize), cache size \(self.downloadManagerUnderTest.getUsedCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
            }
            else{
                
                XCTAssertNotNil(error, "Expected .success, got \(error!))")
                
            }
            
            e.fulfill()
            
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    // test condition: new cacheSize > current usedcachesize
    func testDownloadManagerSetCacheSize_NewCacheSizelargerThanCurrentUsedCacheSize(){
        
        let e = expectation(description: "complationHandler handler invoked")
        let url=URL(string:secondUrlStringUnderTest)!
        
        // first clear cache
        downloadManagerUnderTest.clearCache()
        XCTAssertTrue(0==downloadManagerUnderTest.getUsedCacheSize(),"expected 0 got:\(downloadManagerUnderTest.getUsedCacheSize())")
        
        downloadManagerUnderTest.setMaximumCacheSize(newSize: DownloadManagerConstants.Chache.maxChacheSize)
        XCTAssertTrue(DownloadManagerConstants.Chache.maxChacheSize==downloadManagerUnderTest.getMaximumCacheSize())
        
        _=self.downloadManagerUnderTest.download(url:url ,complationHandler: { (data,error) in
            
            if let result=data{
                
                let objectSize=result.count
                XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "expected data but got nil, Data Size \(objectSize), cache size \(self.downloadManagerUnderTest.getMaximumCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
                
                XCTAssertTrue(objectSize==self.downloadManagerUnderTest.getUsedCacheSize(),"cache size is not equal with downloaded data size. Data Size: \(objectSize), cache size \(self.downloadManagerUnderTest.getUsedCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
                
                // set maximum cache size
                let newCacheSize=UInt(objectSize+10)
                self.downloadManagerUnderTest.setMaximumCacheSize(newSize: newCacheSize)
                XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: url.absoluteString), "expected data but got nil,Data Size \(objectSize), cache size \(self.downloadManagerUnderTest.getUsedCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
            }
            else{
                
                XCTAssertNotNil(error, "Expected .success, got \(error!))")
                
            }
            
            e.fulfill()
            
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    // Cache policy: The cache should evict images not recently used
    func testDownloadManagerCachePolicy(){
        
        let e = expectation(description: "complationHandler handler invoked")
        let e2 = expectation(description: "complationHandler handler invoked")
        let e3 = expectation(description: "complationHandler handler invoked")
        
        
        let moreRecentUrl=URL(string:moreRecentUrlStringUnderTest)!
        let lessRecentUrl=URL(string:lessRecentUrlStringUnderTest)!
        let theMostRecentUrl=URL(string:theMostRecentUrlStringUnderTest)!
        
        // first clear cache
        downloadManagerUnderTest.clearCache()
        XCTAssertTrue(0==downloadManagerUnderTest.getUsedCacheSize(),"expected 0 got:\(downloadManagerUnderTest.getUsedCacheSize())")
        
        downloadManagerUnderTest.setMaximumCacheSize(newSize: 26000)
        
        _=self.downloadManagerUnderTest.download(url:lessRecentUrl ,complationHandler: { (data,error) in
            
            if let result=data{
                
                let objectSize=result.count
                XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: lessRecentUrl.absoluteString), "expected data but got nil, Data Size \(objectSize), cache size \(self.downloadManagerUnderTest.getMaximumCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
                
                XCTAssertTrue(objectSize==self.downloadManagerUnderTest.getUsedCacheSize(),"cache size is not equal with downloaded data size. Data Size: \(objectSize), cache size \(self.downloadManagerUnderTest.getUsedCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
            }
            else{
                
                XCTAssertNotNil(error, "Expected .success, got \(error!))")
            }
            
            e.fulfill()
            
        })
        
        sleep(1)
        _=self.downloadManagerUnderTest.download(url:moreRecentUrl ,complationHandler: { (data,error) in
            
            if let result=data{
                
                let objectSize=result.count
                // cashe still has space both url should be inside the cache
                XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: moreRecentUrl.absoluteString), "expected data but got nil, Data Size \(objectSize), cache size \(self.downloadManagerUnderTest.getUsedCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
                XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: lessRecentUrl.absoluteString), "expected data but got nil, Data Size \(objectSize), cache size \(self.downloadManagerUnderTest.getUsedCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
            }
            else{
                
                XCTAssertNotNil(error, "Expected .success, got \(error!))")
            }
            
            e2.fulfill()
            
        })
        sleep(1)
        _=self.downloadManagerUnderTest.download(url:theMostRecentUrl ,complationHandler: { (data,error) in
            
            if let result=data{
                
                let objectSize=result.count
                
                // the two recent url should be inside the cache
                XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: theMostRecentUrl.absoluteString), "expected data but got nil, Data Size \(objectSize), cache size \(self.downloadManagerUnderTest.getMaximumCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
                XCTAssertNotNil(self.downloadManagerUnderTest.getChachedVersion(url: moreRecentUrl.absoluteString), "expected data but got nil, cache size \(self.downloadManagerUnderTest.getUsedCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
                
                // the less recent url should be removed from cache to let the most recent url be saved inside the cache
                XCTAssertNil(self.downloadManagerUnderTest.getChachedVersion(url: lessRecentUrl.absoluteString), "expected nil but got data, cache size \(self.downloadManagerUnderTest.getUsedCacheSize()),NumberOfCachedObjects:\(self.downloadManagerUnderTest.getNumberOfCachedObjects())")
                
            }
            else{
                
                XCTAssertNotNil(error, "Expected .success, got \(error!))")
            }
            
            e3.fulfill()
            
        })
        waitForExpectations(timeout: 10.0, handler: nil)
        
    }
    
}
