//
//  ViewController.swift
//  GoGoGadgetGithub
//
//  Created by Jeremy Moore on 6/27/16.
//  Copyright © 2016 Jeremy Moore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func requestButtonPressed(sender: AnyObject) {
        
        GithubOAuth.shared.oAuthRequestWith(["scope" : "email,user"])

    }
    
    @IBAction func printButtonPressed(sender: AnyObject) {
        
        do {
            let token = try GithubOAuth.shared.accessToken()
            print("Token is:\(token)")
        } catch let error {
            print (error)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

