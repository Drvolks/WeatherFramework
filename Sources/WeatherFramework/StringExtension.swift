//
//  StringExtension.swift
//  weatherlr
//
//  Created by Jean-Francois Dufour on 2016-04-18.
//  Copyright © 2016 Jean-Francois Dufour. All rights reserved.
//

import Foundation

public extension String {
    func localized() ->String {
        
        let path = Bundle.main.path(forResource: PreferenceHelper.getLanguage().rawValue, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }

    func localized(_ lang: Language) ->String {
        
        let path = Bundle.main.path(forResource: lang.rawValue, ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    struct NumFormatter {
        static let instance = NumberFormatter()
    }
    
    var isDouble: Bool {
        return NumFormatter.instance.number(from: self)?.doubleValue != nil
    }
}