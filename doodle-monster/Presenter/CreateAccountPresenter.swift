//
//  LoginPresenter.swift
//  doodle-monster
//
//  Created by Josh Freed on 12/14/15.
//  Copyright © 2015 BleepSmazz. All rights reserved.
//

import UIKit

protocol CreateAccountView {
    func goToMainMenu()
    func showCreateAccountError()
    func setUsername(_ username: String)
}

protocol CreateAccountViewPresenter {
    init(view: CreateAccountView, api: DoodMonApi, username: String, password: String)
    func createAccount(_ displayName: String, confirmPassword: String)
    func showUsername()
}

class CreateAccountPresenter: CreateAccountViewPresenter {
    let view: CreateAccountView
    let api: DoodMonApi
    let username: String
    let password: String
    
    required init(view: CreateAccountView, api: DoodMonApi, username: String, password: String) {
        self.view = view
        self.api = api
        self.username = username
        self.password = password
    }
    
    func createAccount(_ displayName: String, confirmPassword: String) {
        guard !username.isEmpty && !password.isEmpty else {
            // the previous view controller sent us bad data
            return
        }
        
        if password != confirmPassword {
            // blah blah tell the user to make the passwords match
            return
        }
        
        api.createUser(username, password: password, displayName: displayName) { result in
            switch result {
            case .success: self.view.goToMainMenu()
            case .error: self.view.showCreateAccountError()
            }
        }
    }
    
    func showUsername() {
        self.view.setUsername(username)
    }
}
