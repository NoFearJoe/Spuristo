//
//  IKTracker.swift
//  
//
//  Created by Ilya Kharabet on 17.05.16.
//
//

import Foundation



enum IKTrackerCondition {

    case Once(Int)
    case Every(Int)
    case Quadratic(Int)

}



final class IKTrackerPool {
    
    static let sharedInstance = IKTrackerPool()
    
    
    subscript(key: String) -> IKTracker? {
        get {
            return pool[key]
        }
        set {
            pool[key] = newValue
        }
    }
    
    
    var first: IKTracker? {
        return pool.values.first
    }
    
    
    private var pool = [String: IKTracker]()

}



class IKTracker: NSObject {
    
    private static let identifier = "IKTracker"

    
    typealias IKVoidClosure = () -> ()
    
    
    var checkpoint: IKVoidClosure?
    
    
    private(set) var key: String!
    private(set) var condition: IKTrackerCondition!
    
    
    private(set) var usagesCount: Int = 0
    
    
    private var enabled: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(IKTracker.identifier + key)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: IKTracker.identifier + key)
        }
    }
    
    
    init(key: String, condition: IKTrackerCondition) {
        super.init()
        
        self.key = key
        self.condition = condition
        
        IKTrackerPool.sharedInstance[key] = self
    }
    
    
    func commit() {
        if enabled {
            usagesCount += 1
        }
        
        if satisfiesCondition(usagesCount: usagesCount, condition: condition) {
            checkpoint?()
        }
    }
    
    
    func disable() {
        enabled = false
    }
    
    
    private func satisfiesCondition(usagesCount count: Int, condition: IKTrackerCondition) -> Bool {
        switch condition {
        case .Once(let targetCount):
            return enabled && usagesCount == targetCount
        case .Every(let targetCount):
            return enabled && usagesCount == targetCount
        case .Quadratic(let targetCount):
            let power = log(Double(usagesCount)) / log(Double(targetCount))
            return enabled && floor(power) == power && power != 0
        }
    }
    
    private func setEnabledByCondition(condition: IKTrackerCondition) {
        switch condition {
        case .Once(_):
            enabled = false
            break
        case .Every(let targetCount):
            if targetCount == Int.max {
                enabled = false
            }
            break
        case .Quadratic(let targetCount):
            if targetCount == Int.max {
                enabled = false
            }
            break
        }
    }
    

}


