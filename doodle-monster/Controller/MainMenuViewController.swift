//
//  MainMenuViewController.swift
//  doodle-monster
//
//  Created by Josh Freed on 12/23/15.
//  Copyright © 2015 BleepSmazz. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet weak var yourTurnCollection: UICollectionView!
    @IBOutlet weak var waitingCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewMonster" {
            if let vc = segue.destinationViewController as? NewMonsterViewController {
                vc.viewModel = NewMonsterViewModel(userService: appDelegate.userService)
            }
        }
    }
    
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {
    }

    @IBAction func signOut(sender: UIButton) {
        
    }
}
