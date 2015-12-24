//
//  InviteByEmailViewModel.swift
//  doodle-monster
//
//  Created by Josh Freed on 12/24/15.
//  Copyright © 2015 BleepSmazz. All rights reserved.
//

import UIKit

protocol InviteByEmailViewModelProtocol: class {
    var players: [PlayerViewModelProtocol] { get }
    var playersDidChange: ((InviteByEmailViewModelProtocol) -> ())? { get set }
    
    init(userService: UserService)
    func search(text: String)
    func playerAt(index: Int) -> PlayerViewModelProtocol
}

protocol PlayerViewModelProtocol {
    var email: String { get }
    var displayName: String { get }
    
    init(player: Player)
}

class InviteByEmailViewModel: InviteByEmailViewModelProtocol {
    var players: [PlayerViewModelProtocol] = [] {
        didSet {
            playersDidChange?(self)
        }
    }
    
    var playersDidChange: ((InviteByEmailViewModelProtocol) -> ())?
    
    private let userService: UserService
    
    required init(userService: UserService) {
        self.userService = userService
    }
    
    func search(text: String) {
        userService.search(text) { result in
            switch result {
            case .Success(let players):
                var viewModels: [PlayerViewModelProtocol] = []
                for player in players {
                    viewModels.append(PlayerViewModel(player: player))
                }
                self.players = viewModels
                break
            case .Error: break
            }
        }
    }

    func playerAt(index: Int) -> PlayerViewModelProtocol {
        return players[index]
    }
}

class PlayerViewModel: PlayerViewModelProtocol {
    var email: String {
        return player.email
    }
    var displayName: String {
        return player.displayName
    }
    
    private let player: Player
    
    required init(player: Player) {
        self.player = player
    }
}