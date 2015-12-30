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
    var playerWasSelected: ((PlayerViewModelProtocol) -> ())? { get set }
    
    init(userService: UserService)
    func search(text: String)
    func playerAt(index: Int) -> PlayerViewModelProtocol
    func selectPlayer(index: NSIndexPath)
}

class InviteByEmailViewModel: InviteByEmailViewModelProtocol {
    var players: [PlayerViewModelProtocol] = [] {
        didSet {
            playersDidChange?(self)
        }
    }
    
    var playersDidChange: ((InviteByEmailViewModelProtocol) -> ())?
    var playerWasSelected: ((PlayerViewModelProtocol) -> ())?
    
    private let userService: UserService
    private var playerModels: [Player] = []
    
    required init(userService: UserService) {
        self.userService = userService
    }
    
    func search(text: String) {
        userService.search(text) { result in
            switch result {
            case .Success(let players):
                self.playerModels = players
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

    func selectPlayer(index: NSIndexPath) {
        playerWasSelected?(players[index.row])
    }
}