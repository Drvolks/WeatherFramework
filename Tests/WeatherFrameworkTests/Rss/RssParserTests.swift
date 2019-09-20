//
//  RssParserTests.swift
//  weatherlr
//
//  Created by Jean-Francois Dufour on 2016-04-04.
//  Copyright © 2016 Jean-Francois Dufour. All rights reserved.
//

#if !os(watchOS)
import XCTest
@testable import WeatherFramework

class RssParserTests: XCTestCase {
    func testRssParserConstructor() {
        let file = try! TestResource(name: "TestData", type: "xml")
        let xmlData = try! Data(contentsOf: file.url)
        
        let result = RssParser(xmlData: xmlData, language: Language.French)
        XCTAssertNotNil(result)
    }
    
    func testRssParserConstructorWithUrl() {
        if let url = URL(string: "https://meteo.gc.ca/rss/city/qc-147_f.xml") {
            let result = RssParser(url: url, language: Language.French)
            XCTAssertNotNil(result)
        } else {
            XCTFail("Erreur NSURL")
        }
    }
    
    func testParse() {
        let file = try! TestResource(name: "TestData", type: "xml")
        let xmlData = try! Data(contentsOf: file.url)
            
        let parser = RssParser(xmlData: xmlData, language: Language.French)
        let result = parser.parse()
        XCTAssertNotNil(result)
        XCTAssertEqual(14, result.count)
            
        for i in 0..<result.count {
            XCTAssertNotNil(result[i].title)
            XCTAssertFalse(result[i].title.isEmpty)
        }
    }
    
    func testParseFromUrl() {
        if let url = URL(string: "https://meteo.gc.ca/rss/city/qc-147_f.xml") {
            if let parser = RssParser(url: url, language: Language.French) {
                let result = parser.parse()
                XCTAssertNotNil(result)
                XCTAssertTrue(result.count > 7)
                
                for i in 0..<result.count {
                    XCTAssertNotNil(result[i].title)
                    XCTAssertFalse(result[i].title.isEmpty)
                }
            } else {
                XCTFail("Erreur RssParser")
            }
        }
        else {
            XCTFail("Erreur NSURL")
        }
    }
    
    func testParsePerformance() {
        self.measure {
            let file = try! TestResource(name: "TestData", type: "xml")
            let xmlData = try! Data(contentsOf: file.url)
            let parser = RssParser(xmlData: xmlData, language: Language.French)
            let result = parser.parse()
            XCTAssertEqual(14, result.count)
        }
    }
}
#endif
