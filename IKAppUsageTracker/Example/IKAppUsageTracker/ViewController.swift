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
    
    
    private var onceConditionTracker: IKTracker!
    private var everyConditionTracker: IKTracker!
    private var quadraticConditionTracker: IKTracker!
    
    private var sharedTracker: IKTracker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onceConditionTracker = IKTracker(key: "onceConditionTracker", condition: IKTrackerCondition.Once(2))
        onceConditionTracker.checkpoint = { [weak self] _ in
            self?.showRateDialog("\"Once condition\" tracker", tracker: self?.onceConditionTracker)
        }
        everyConditionTracker = IKTracker(key: "everyConditionTracker", condition: IKTrackerCondition.Every(2))
        everyConditionTracker.checkpoint = { [weak self] _ in
            self?.showRateDialog("\"Every condition\" tracker", tracker: self?.everyConditionTracker)
        }
        quadraticConditionTracker = IKTracker(key: "quadraticConditionTracker", condition: IKTrackerCondition.Quadratic(2))
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        onceConditionButton.setTitle("Once condition. Usages count: \(onceConditionTracker.usagesCount)", forState: .Normal)
        onceConditionButton.enabled = onceConditionTracker.enabled
        everyConditionButton.setTitle("Every condition. Usages count: \(everyConditionTracker.usagesCount)", forState: .Normal)
        everyConditionButton.enabled = everyConditionTracker.enabled
        quadraticConditionButton.setTitle("Quadratic condition. Usages count: \(quadraticConditionTracker.usagesCount)", forState: .Normal)
        quadraticConditionButton.enabled = quadraticConditionTracker.enabled
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    private func showRateDialog(message: String, tracker: IKTracker?) {
        let alert = UIAlertController(title: "Checkpoint", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Destructive, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func onOnceConditionButtonTouched(sender: UIButton) {
        onceConditionTracker.commit()
        sharedTracker?.commit()
        sender.setTitle("Once condition. Usages count: \(onceConditionTracker.usagesCount)", forState: .Normal)
        sender.enabled = onceConditionTracker.enabled
    }
    
    @IBAction func onEveryConditionButtonTouched(sender: UIButton) {
        everyConditionTracker.commit()
        sharedTracker?.commit()
        sender.setTitle("Every condition. Usages count: \(everyConditionTracker.usagesCount)", forState: .Normal)
        sender.enabled = everyConditionTracker.enabled
    }
    
    @IBAction func onQuadraticConditionButtonTouched(sender: UIButton) {
        quadraticConditionTracker.commit()
        sharedTracker?.commit()
        sender.setTitle("Quadratic condition. Usages count: \(quadraticConditionTracker.usagesCount)", forState: .Normal)
        sender.enabled = quadraticConditionTracker.enabled
    }


}

