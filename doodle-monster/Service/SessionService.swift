//
//  SessionService.swift
//  doodle-monster
//
//  Created by Josh Freed on 2/5/16.
//  Copyright © 2016 BleepSmazz. All rights reserved.
//

import UIKit

protocol SessionService {
    var currentPlayer: Player? { get }
    var token: String? { get }

    func hasSession() -> Bool
    func tryToLogIn(_ username: String, password: String, callback: @escaping (LoginResult) -> ())
    func logout()
    func resume()
    func setAuthToken(_ token: String, andPlayer playerDict: NSDictionary)
}

