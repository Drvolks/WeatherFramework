//
//  RssParserStub.swift
//  weatherlr
//
//  Created by Jean-Francois Dufour on 2016-04-05.
//  Copyright © 2016 Jean-Francois Dufour. All rights reserved.
//

import UIKit
@testable import WeatherFramework

class RssParserStub : RssParser {
    convenience init?() {
        self.init(xmlName: "TestData", language: Language.French)
    }
    
    convenience init?(xmlName: String) {
        self.init(xmlName: xmlName, language: Language.French)
    }
    
    init?(xmlName: String, language: Language) {
        let file = try! TestResource(name: xmlName, type: "xml")
        let xmlData = try! Data(contentsOf: file.url)
        super.init(xmlData: xmlData, language: language)
    }
}
