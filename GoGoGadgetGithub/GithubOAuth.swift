//
//  GithubOAuth.swift
//  GoGoGithub
//
//  Created by Jeremy Moore on 6/27/16.
//  Copyright © 2016 Jeremy Moore. All rights reserved.
//

import UIKit

let kAccessTokenKey = "kAccessTokenKey"
let kOAuthBaseURLString = "https://github.com/login/oauth/"
let kAccessTokenRegexPattern = "access_token=([^&]+)"

typealias GitHubOAuthCompletion = (success: Bool) -> ()

enum GithubOAuthError: ErrorType {
    case MissingAccessToken(String)
    case ExtractingTokenFromString(String)
    case ExtractingTemporaryCode(String)
    case ResponseFromGitHub(String)
}

enum SaveOptions: Int {
    case userDefaults
}

class GithubOAuth {
    
    static let shared = GithubOAuth()
    
    private init(){}
    
    func oAuthRequestWith(parameters: [String : String]) {
        
        var parametersString = String()
        
        for parameter in parameters.values {
            parametersString = parametersString.stringByAppendingString(parameter)
        }
        
        if let requestURL = NSURL(string: "\(kOAuthBaseURLString)authorize?client_id=\(kGithubClientID)&scope=\(parametersString)") {
            
            print(requestURL)
            
            UIApplication.sharedApplication().openURL(requestURL)
        }
    }
    
    func temporaryCodeFromCallback(url: NSURL) throws -> String {
        guard let temporaryCode = url.absoluteString.componentsSeparatedByString("=").last else {
            throw GithubOAuthError.ExtractingTemporaryCode("Error extracting temp code from github callback")
        }
        print (temporaryCode)
        return temporaryCode
    }
    
        
    func stringWith(data: NSData) -> String? {
        let byteBuffer : UnsafeBufferPointer<UInt8> = UnsafeBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(data.bytes), count: data.length)
        
        let result = String(bytes: byteBuffer, encoding: NSASCIIStringEncoding)
        
        return result
    }
        
        
    func accessTokenFromString(string: String) throws -> String? {
        
        do{
            
            let regex = try NSRegularExpression(pattern: kAccessTokenRegexPattern, options: NSRegularExpressionOptions.CaseInsensitive)
            
            let matches = regex.matchesInString(string, options: .Anchored, range: NSMakeRange(0, string.characters.count))
            
            if matches.count > 0 {
                for(_, value) in matches.enumerate() {
                    let matchRange = value.rangeAtIndex(1)
                    return (string as NSString).substringWithRange(matchRange)
                }
                
            }
        } catch _ {
            throw GithubOAuthError.ExtractingTokenFromString("Error extracting token")
        }
        return nil
    }
        
    func saveAccessTokenToUserDefaults(accessToken: String) -> Bool {
        
        NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: kAccessTokenKey)
        
        return NSUserDefaults.standardUserDefaults().synchronize()
        
    }
        
    func tokenRequestWithCallback(url: NSURL, options: SaveOptions, completion: GitHubOAuthCompletion) {
        
        do {
            
            let temporaryCode = try self.temporaryCodeFromCallback(url)
            
            let requestString = "\(kOAuthBaseURLString)access_token?client_id=\(kGithubClientID)&client_secret=\(kGithubClientSecret)&code=\(temporaryCode)"
            
            if let requestURL = NSURL(string: requestString) {
                
                let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
                
                let session = NSURLSession(configuration: sessionConfiguration)
                
                session.dataTaskWithURL(requestURL, completionHandler: { (data, response, error)  in
                    
                    if let _ = error {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            completion(success: false); return
                        })
                    }
                    
                    if let data = data {
                        print(data)
                        if let tokenString = self.stringWith(data) {
                            do {
                                if let token = try self.accessTokenFromString(tokenString) {
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ completion(success: self.saveAccessTokenToUserDefaults(token))
                                    })
                                }
                            } catch _ {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    completion(success: false)
                                    print("error stringifying token")
                                })
                            }
                        }
                    }
                }).resume()
            }
        } catch _ {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                completion(success: false)
                print("error stringifying token")
            })
        }
    }

    func accessToken() throws -> String? {
        
        guard let accessToken = NSUserDefaults.standardUserDefaults().stringForKey(kAccessTokenKey) else {
            throw GithubOAuthError.MissingAccessToken("No token saved")
        }
        return accessToken
    }
}
    