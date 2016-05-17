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



enum IKTrackerType {
    
    case Counter
    
}




final class IKTrackerPool {
    
    static let sharedInstance = IKTrackerPool()

}



class IKTracker: NSObject {

    typealias IKVoidClosure = () -> ()
    typealias IKBoolClosure = (Bool) -> ()
    typealias IKIntClosure  = (Int) -> ()
    
    
    init(type: IKTrackerType) {
        super.init()
        
        
    }

}


