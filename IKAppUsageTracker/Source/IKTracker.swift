//
//  Tracker.swift
//  
//
//  Created by Ilya Kharabet on 17.05.16.
//
//

import Foundation


typealias VoidClosure = () -> ()


/**
 Enum of checkpoint call conditions
 
 - Once:      Tracker will call checkpiont once after N usages
 - Every:     Tracker will call checkpoint every N usages
 - Quadratic: Tracker will call checkpoint every time when usages count is power of N
 */
enum TrackerCondition {
    
    /// Tracker will call checkpiont once after N usages
    case Once(UInt)
    
    /// Tracker will call checkpoint every N usages
    case Every(UInt)
    
    /// Tracker will call checkpoint every power of N
    case Quadratic(UInt)
    
}


/// Tracker class instances pool. Use TrackerPool.sharedInstance[KEY] for getting Tracker instance with desired KEY
final class TrackerPool {
    
    /// TrackerPool shared instance
    static let sharedInstance = TrackerPool()
    
    
    subscript(key: String) -> Tracker? {
        get {
            return pool[key]
        }
        set {
            pool[key] = newValue
        }
    }
    
    
    var first: Tracker? {
        return Array(pool.values).first
    }
    
    var last: Tracker? {
        return Array(pool.values).last
    }
    
    
    private var pool = [String: Tracker]()
    
}


class Tracker {
    
    /// Class identifier
    private static let identifier: String = NSStringFromClass(Tracker.self)
    
    
    /// Closure fired when usages count satisfies the condition
    var checkpoint: VoidClosure?
    
    
    /// Identification key
    private(set) var key: String!
    private(set) var condition: TrackerCondition!
    
    
    /// Usages counter
    private(set) var usagesCount: UInt {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey(Tracker.identifier + key + "usagesCount") ?? 0) as! UInt
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Tracker.identifier + key + "usagesCount")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    /// Returns true if tracker enabled
    private(set) var enabled: Bool {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey(Tracker.identifier + key + "enabled") ?? true) as! Bool
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Tracker.identifier + key + "enabled")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    
    /**
     Tracker initializer. This instance will be automatically added to TrackerPool
     
     - parameter key:       Identification key
     - parameter condition: Condition type
     
     - returns: Instance of Tracker class
     */
    init(key: String, condition: TrackerCondition) {
        self.key = key
        self.condition = condition
        
        TrackerPool.sharedInstance[key] = self
    }
    
    
    /**
     Commits usage. Increments usages count by 1 and check if usages count satisfies condition
     */
    func commit() {
        if enabled {
            if usagesCount < UInt.max {
                usagesCount += 1
            }
        }
        
        if satisfiesCondition(usagesCount: usagesCount, condition: condition) {
            checkpoint?()
        }
        
        setEnabledByCondition(usagesCount, condition: condition)
    }
    
    /**
     Returns tracker to initial state (usages count = 0 and enabled = true)
     */
    func drop() {
        usagesCount = 0
        enabled = true
    }
    
    
    /**
     Sets tracker disabled. WARNING: Tracker never been work after calling of this function!
     */
    func disable() {
        enabled = false
    }
    
    
    /**
     Checks if usages count saticfies condition
     
     - parameter count:     Usages count
     - parameter condition: Condition type
     
     - returns: True if satisfies
     */
    private func satisfiesCondition(usagesCount count: UInt, condition: TrackerCondition) -> Bool {
        switch condition {
        case .Once(let targetCount):
            return enabled && usagesCount == targetCount
        case .Every(let targetCount):
            return enabled && Double(usagesCount) % Double(targetCount) == 0
        case .Quadratic(let targetCount):
            let power = log(Double(usagesCount)) / log(Double(targetCount))
            return enabled && floor(power) == power && power != 0
        }
    }
    
    /**
     Sets tracker disabled if needed
     
     - parameter condition: Condition type
     */
    private func setEnabledByCondition(usagesCount: UInt, condition: TrackerCondition) {
        switch condition {
        case .Once(_):
            enabled = false
            break
        case .Every(_):
            if usagesCount >= UInt.max {
                enabled = false
            }
            break
        case .Quadratic(_):
            if usagesCount >= UInt.max {
                enabled = false
            }
            break
        }
    }
    
    
}
