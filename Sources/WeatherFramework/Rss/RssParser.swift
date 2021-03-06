//
//  RssParser.swift
//  weatherlr
//
//  Created by Jean-Francois Dufour on 2016-04-04.
//  Copyright © 2016 Jean-Francois Dufour. All rights reserved.
//

import UIKit

public class RssParser : RssParserBase {
    var parser:XMLParser
    var rssEntries = [RssEntry]()
    var language:Language
    
    let entryElement = "entry"
    
    public init(xmlData: Data, language: Language) {
        parser = XMLParser(data: xmlData)
        self.language = language
    }
    
    public init?(url: URL, language: Language) {
        if let tryParser = XMLParser(contentsOf: url) {
            parser = tryParser
        } else {
            return nil
        }
        
        self.language = language
    }
    
    public func parse() -> [RssEntry] {
        parser.delegate = self
        parser.parse()
        
        return rssEntries
    }
    
    public override func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        super.parser(parser, didStartElement: elementName, namespaceURI: namespaceURI, qualifiedName: qName, attributes: attributeDict)
        switch elementName {
        case entryElement:
            let rssEntry = RssEntry(parent: self, language: language)
            parser.delegate = rssEntry
            rssEntries.append(rssEntry)
        default: break
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }
    
    

}
