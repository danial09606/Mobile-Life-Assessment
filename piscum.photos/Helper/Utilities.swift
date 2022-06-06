//
//  Utilities.swift
//  piscum.photos
//
//  Created by Danial Fajar on 05/06/2022.
//
import UIKit


//Dynamic Url for API
class mainURL {
    class func webService() -> String {
        var url: String = ""
        
        if UIApplication.shared.inferredEnvironment == .testFlight {
            url = "https://picsum.photos/"
        } else {
            url = "https://picsum.photos/"
        }
        
        return url
    }
}
