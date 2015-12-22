//
//  UserService.swift
//  doodle-monster
//
//  Created by Josh Freed on 12/22/15.
//  Copyright © 2015 BleepSmazz. All rights reserved.
//

import UIKit
import Parse

protocol UserService {
    func tryToLogIn(username: String, password: String, callback: (result: LoginResult) -> ())
    func createUser(username: String, password: String, displayName: String, callback: (result: CreateUserResult) -> ())
}

class ParseUserService: UserService {
    func tryToLogIn(username: String, password: String, callback: (result: LoginResult) -> ()) {
        PFUser.query()?.whereKey("username", equalTo: username).getFirstObjectInBackgroundWithBlock() { (user, error) -> Void in
            if let error = error {
                if error.code == 101 {
                    callback(result: .NoSuchUser)
                    return
                } else {
                    // Some other error occurred other than the "allowed" error "user not found"
                    callback(result: .Error)
                    return
                }
            }

            guard user != nil else {
                // so what does this mean? That the query succeeded without an error but there was no user object returned?
                // But it seems when a parse search does not find a result it actually sends back an error above
                // So I don't know if it's possible to get here or what it even means if it happens
                print("do what now?")
                callback(result: .Error)
                return
            }

            PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
                // todo handle errors
                
                callback(result: .Success)
            }
        }
    }
    
    func createUser(username: String, password: String, displayName: String, callback: (result: CreateUserResult) -> ()) {
        let user = PFUser()
        user.username = username
        user.password = password
        user["displayName"] = displayName
        user.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                callback(result: .Error)
            } else {
                callback(result: .Success)
            }
        }
    }
}

enum LoginResult {
    case Success
    case NoSuchUser
    case Error
}

enum CreateUserResult {
    case Success
    case Error
}