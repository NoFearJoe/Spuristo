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
    
    fileprivate var sharedTracker: Tracker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Tracker.register(with: "onceConditionTracker", condition: TrackerCondition.once(2))
        Tracker.obtain(for: "onceConditionTracker")?.checkpoint = { [weak self] _ in
            self?.showRateDialog("\"Once condition\" tracker", tracker: Tracker.obtain(for: "onceConditionTracker"))
        }
        Tracker.register(with: "everyConditionTracker", condition: TrackerCondition.every(2))
        Tracker.obtain(for: "everyConditionTracker")?.checkpoint = { [weak self] _ in
            self?.showRateDialog("\"Every condition\" tracker", tracker: Tracker.obtain(for: "everyConditionTracker"))
        }
        Tracker.register(with: "quadraticConditionTracker", condition: TrackerCondition.quadratic(2))
        Tracker.obtain(for: "quadraticConditionTracker")?.checkpoint = { [weak self] _ in
            self?.showRateDialog("\"Quadratic condition\" tracker", tracker: Tracker.obtain(for: "quadraticConditionTracker"))
        }
        
        if let sharedTracker = Tracker.obtain(for: "saredTracker") {
            self.sharedTracker = sharedTracker
            self.sharedTracker?.checkpoint = { [weak self] _ in
                self?.showRateDialog("Shared tracker", tracker: self?.sharedTracker)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        onceConditionButton.setTitle("Once condition. Usages count: \(Tracker.obtain(for: "onceConditionTracker")?.usagesCount ?? 0)",
            for: UIControlState())
        onceConditionButton.isEnabled = Tracker.obtain(for: "onceConditionTracker")?.enabled ?? false
        everyConditionButton.setTitle("Every condition. Usages count: \(Tracker.obtain(for: "everyConditionTracker")?.usagesCount ?? 0)", for: UIControlState())
        everyConditionButton.isEnabled = Tracker.obtain(for: "everyConditionTracker")?.enabled ?? false
        quadraticConditionButton.setTitle("Quadratic condition. Usages count: \(Tracker.obtain(for: "quadraticConditionTracker")?.usagesCount ?? 0)",
            for: UIControlState())
        quadraticConditionButton.isEnabled = Tracker.obtain(for: "quadraticConditionTracker")?.enabled ?? false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    fileprivate func showRateDialog(_ message: String, tracker: Tracker?) {
        let alert = UIAlertController(title: "Checkpoint", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func onOnceConditionButtonTouched(_ sender: UIButton) {
        guard let tracker = Tracker.obtain(for: "onceConditionTracker") else { return }
        tracker.commit()
        sharedTracker?.commit()
        sender.setTitle("Once condition. Usages count: \(tracker.usagesCount)", for: UIControlState())
        sender.isEnabled = tracker.enabled
    }
    
    @IBAction func onEveryConditionButtonTouched(_ sender: UIButton) {
        guard let tracker = Tracker.obtain(for: "everyConditionTracker") else { return }
        tracker.commit()
        sharedTracker?.commit()
        sender.setTitle("Every condition. Usages count: \(tracker.usagesCount)", for: UIControlState())
        sender.isEnabled = tracker.enabled
    }
    
    @IBAction func onQuadraticConditionButtonTouched(_ sender: UIButton) {
        guard let tracker = Tracker.obtain(for: "quadraticConditionTracker") else { return }
        tracker.commit()
        sharedTracker?.commit()
        sender.setTitle("Quadratic condition. Usages count: \(tracker.usagesCount)", for: UIControlState())
        sender.isEnabled = tracker.enabled
    }


}

