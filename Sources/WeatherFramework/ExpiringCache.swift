//
//  ExpiringCache.swift
//  weatherlr
//
//  Created by Jean-Francois Dufour on 2016-04-25.
//  Copyright © 2016 Jean-Francois Dufour. All rights reserved.
//

import Foundation

class ExpiringCache : NSCache<NSString, AnyObject> {
    static let instance = ExpiringCache()
    
    fileprivate let ExpiringCacheObjectKey = "expireObjectKey"
    fileprivate let ExpiringCacheDefaultTimeout: TimeInterval = 60 * Double(Global.weatherCacheInMinutes)
    
    override init() {
        super.init()
        countLimit = 10
    }
    
    func setObject(_ obj: AnyObject, forKey key: NSString, timeout: TimeInterval) {
        super.setObject(obj, forKey: key)
        Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.removeObject(forKey: key)
        }
    }

    override func setObject(_ obj: AnyObject, forKey key: NSString) {
         self.setObject(obj, forKey: key, timeout: ExpiringCacheDefaultTimeout)
    }
}
