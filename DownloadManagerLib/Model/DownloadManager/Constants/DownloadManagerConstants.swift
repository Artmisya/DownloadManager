//
//  Constants.swift
//  DownloadManager
//
//  Created by Saeedeh on 06/05/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation

struct DownloadManagerConstants {
    
    struct Chache{
        static let maxChacheSize:UInt=20000000
    }
    
    struct ErrorMessage{
        static let badUrl:String="Bad Url"
        static let serverError:String="Server Error"
        static let fileError:String="The downloaded file was corrupted."
        static let unknownError="Whoops, something went wrong!"
    }
    
    struct DomainError{
        static let fileError:String="FileError"
        static let serverError:String="ServerError"
        static let httpError:String="HttpError"
    }
}
