//
//  ViewController.swift
//  IKAppUsageTracker
//
//  Created by Ilya Kharabet on 17.05.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var onceConditionButton: UIButton!
    @IBOutlet weak var everyConditionButton: UIButton!
    @IBOutlet weak var quadraticConditionButton: UIButton!
    
    
    fileprivate var onceConditionTracker: IKTracker!
    fileprivate var everyConditionTracker: IKTracker!
    fileprivate var quadraticConditionTracker: IKTracker!
    
    fileprivate var sharedTracker: IKTracker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onceConditionTracker = IKTracker(key: "onceConditionTracker", condition: IKTrackerCondition.once(2))
        onceConditionTracker.checkpoint = { [weak self] _ in
            self?.showRateDialog("\"Once condition\" tracker", tracker: self?.onceConditionTracker)
        }
        everyConditionTracker = IKTracker(key: "everyConditionTracker", condition: IKTrackerCondition.every(2))
        everyConditionTracker.checkpoint = { [weak self] _ in
            self?.showRateDialog("\"Every condition\" tracker", tracker: self?.everyConditionTracker)
        }
        quadraticConditionTracker = IKTracker(key: "quadraticConditionTracker", condition: IKTrackerCondition.quadratic(2))
        quadraticConditionTracker.checkpoint = { [weak self] _ in
            self?.showRateDialog("\"Quadratic condition\" tracker", tracker: self?.quadraticConditionTracker)
        }
        
        if let sharedTracker = IKTrackerPool.sharedInstance["saredTracker"] {
            self.sharedTracker = sharedTracker
            self.sharedTracker?.checkpoint = { [weak self] _ in
                self?.showRateDialog("Shared tracker", tracker: self?.sharedTracker)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        onceConditionButton.setTitle("Once condition. Usages count: \(onceConditionTracker.usagesCount)", for: UIControlState())
        onceConditionButton.isEnabled = onceConditionTracker.enabled
        everyConditionButton.setTitle("Every condition. Usages count: \(everyConditionTracker.usagesCount)", for: UIControlState())
        everyConditionButton.isEnabled = everyConditionTracker.enabled
        quadraticConditionButton.setTitle("Quadratic condition. Usages count: \(quadraticConditionTracker.usagesCount)", for: UIControlState())
        quadraticConditionButton.isEnabled = quadraticConditionTracker.enabled
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    fileprivate func showRateDialog(_ message: String, tracker: IKTracker?) {
        let alert = UIAlertController(title: "Checkpoint", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func onOnceConditionButtonTouched(_ sender: UIButton) {
        onceConditionTracker.commit()
        sharedTracker?.commit()
        sender.setTitle("Once condition. Usages count: \(onceConditionTracker.usagesCount)", for: UIControlState())
        sender.isEnabled = onceConditionTracker.enabled
    }
    
    @IBAction func onEveryConditionButtonTouched(_ sender: UIButton) {
        everyConditionTracker.commit()
        sharedTracker?.commit()
        sender.setTitle("Every condition. Usages count: \(everyConditionTracker.usagesCount)", for: UIControlState())
        sender.isEnabled = everyConditionTracker.enabled
    }
    
    @IBAction func onQuadraticConditionButtonTouched(_ sender: UIButton) {
        quadraticConditionTracker.commit()
        sharedTracker?.commit()
        sender.setTitle("Quadratic condition. Usages count: \(quadraticConditionTracker.usagesCount)", for: UIControlState())
        sender.isEnabled = quadraticConditionTracker.enabled
    }


}

