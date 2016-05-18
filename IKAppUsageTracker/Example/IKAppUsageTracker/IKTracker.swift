//
//  IKTracker.swift
//  
//
//  Created by Ilya Kharabet on 17.05.16.
//
//

import Foundation


typealias IKVoidClosure = () -> ()


/**
 Tracker condition types
 
 - Once:      Tracker will evaluate checkpiont once after N usages
 - Every:     Tracker will evaluate checkpoint every N usages
 - Quadratic: Tracker will evaluate checkpoint every time when usages count is power of N
 */
enum IKTrackerCondition {
    
    /// Tracker will evaluate checkpiont once after N usages
    case Once(UInt)
    
    /// Tracker will evaluate checkpoint every N usages
    case Every(UInt)
    
    /// Tracker will evaluate checkpoint every power of N
    case Quadratic(UInt)
    
}


/// IKTracker class instances pool. Use IKTrackerPool.sharedInstance[KEY] for getting IKTracker instance with desird KEY
final class IKTrackerPool {
    
    /// IKTrackerPool shared instance
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
        return Array(pool.values).first
    }
    
    var last: IKTracker? {
        return Array(pool.values).last
    }
    
    
    private var pool = [String: IKTracker]()
    
}


class IKTracker {
    
    /// Class identifier
    private static let identifier: String = NSStringFromClass(IKTracker.self)
    
    /// Closure fired when usages count satisfies the condition
    var checkpoint: IKVoidClosure?
    
    /// Identification key
    private(set) var key: String!
    private(set) var condition: IKTrackerCondition!
    
    /// Usages counter
    private(set) var usagesCount: UInt {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey(IKTracker.identifier + key + "usagesCount") ?? 0) as! UInt
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: IKTracker.identifier + key + "usagesCount")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    /// Return true if tracker enabled
    private(set) var enabled: Bool {
        get {
            return (NSUserDefaults.standardUserDefaults().objectForKey(IKTracker.identifier + key + "enabled") ?? true) as! Bool
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: IKTracker.identifier + key + "enabled")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    /**
     IKTracker initializer. This instance will be automatically added to IKTrackerPool
     
     - parameter key:       Identification key
     - parameter condition: Condition type
     
     - returns: Instance of IKTracker class
     */
    init(key: String, condition: IKTrackerCondition) {
        self.key = key
        self.condition = condition
        
        IKTrackerPool.sharedInstance[key] = self
    }
    
    /**
     Commit usage. Increment usages count by 1 and check if usages count satisfies condition
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
     Return tracker to initial state (usages count = 0 and enabled = true)
     */
    func drop() {
        usagesCount = 0
        enabled = true
    }
    
    
    /**
     Set tracker disabled. WARNING: Tracker never been work after evaluating of this function!
     */
    func disable() {
        enabled = false
    }
    
    /**
     Check if usages count saticfies condition
     
     - parameter count:     Usages count
     - parameter condition: Condition type
     
     - returns: True if satisfies
     */
    private func satisfiesCondition(usagesCount count: UInt, condition: IKTrackerCondition) -> Bool {
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
     Set tracker disabled if needed
     
     - parameter condition: Condition type
     */
    private func setEnabledByCondition(usagesCount: UInt, condition: IKTrackerCondition) {
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

