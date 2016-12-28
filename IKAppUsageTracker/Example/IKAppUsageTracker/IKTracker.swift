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
    case once(UInt)
    
    /// Tracker will evaluate checkpoint every N usages
    case every(UInt)
    
    /// Tracker will evaluate checkpoint every power of N
    case quadratic(UInt)
    
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
    
    
    fileprivate var pool = [String: IKTracker]()
    
}


class IKTracker {
    
    /// Class identifier
    fileprivate static let identifier: String = NSStringFromClass(IKTracker.self)
    
    /// Closure fired when usages count satisfies the condition
    var checkpoint: IKVoidClosure?
    
    /// Identification key
    fileprivate(set) var key: String!
    fileprivate(set) var condition: IKTrackerCondition!
    
    /// Usages counter
    fileprivate(set) var usagesCount: UInt {
        get {
            return (UserDefaults.standard.object(forKey: IKTracker.identifier + key + "usagesCount") ?? 0) as! UInt
        }
        set {
            UserDefaults.standard.set(newValue, forKey: IKTracker.identifier + key + "usagesCount")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Return true if tracker enabled
    fileprivate(set) var enabled: Bool {
        get {
            return (UserDefaults.standard.object(forKey: IKTracker.identifier + key + "enabled") ?? true) as! Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: IKTracker.identifier + key + "enabled")
            UserDefaults.standard.synchronize()
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
    fileprivate func satisfiesCondition(usagesCount count: UInt, condition: IKTrackerCondition) -> Bool {
        switch condition {
        case .once(let targetCount):
            return enabled && usagesCount == targetCount
        case .every(let targetCount):
            return enabled && Double(usagesCount).truncatingRemainder(dividingBy: Double(targetCount)) == 0
        case .quadratic(let targetCount):
            let power = log(Double(usagesCount)) / log(Double(targetCount))
            return enabled && floor(power) == power && power != 0
        }
    }
    
    /**
     Set tracker disabled if needed
     
     - parameter condition: Condition type
     */
    fileprivate func setEnabledByCondition(_ usagesCount: UInt, condition: IKTrackerCondition) {
        switch condition {
        case .once(_):
            enabled = false
            break
        case .every(_):
            if usagesCount >= UInt.max {
                enabled = false
            }
            break
        case .quadratic(_):
            if usagesCount >= UInt.max {
                enabled = false
            }
            break
        }
    }
    
    
}

