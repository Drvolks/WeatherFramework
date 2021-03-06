//
//  RssEntry.swift
//  weatherlr
//
//  Created by Jean-Francois Dufour on 2016-04-05.
//  Copyright © 2016 Jean-Francois Dufour. All rights reserved.
//

import UIKit

public class RssEntry : RssParserBase {
    public var title = ""
    public var updated = ""
    public var summary = ""
    public var category = ""
    public var day = 0
    public var language:Language
    public var parent:RssParser
    public var link:String = ""
    
    let titleElement = "title"
    let categoryElement = "category"
    let summaryElement = "summary"
    let updatedElement = "updated"
    let entryElement = "entry"
    let linkElement = "link"
    let termAttribute = "term"
    let hrefAttribute = "href"
    
    public init(parent: RssParser, language: Language) {
        self.parent = parent
        self.language = language
    }
    
    public init(parent: RssParser) {
        self.parent = parent
        self.language = Language.French
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case titleElement:
            self.title = removeLiveBreaks(foundCharacters)
            break
        case categoryElement:
            if let term = currentAttributes[termAttribute] {
                self.category = term
            }
            break
        case updatedElement:
            self.updated = removeLiveBreaks(foundCharacters)
            break
        case summaryElement:
            self.summary = removeLiveBreaks(foundCharacters)
            break
        case linkElement:
            if let href = currentAttributes[hrefAttribute] {
                self.link = href
            }
            break
        case entryElement:
            parent.parser.delegate = parent
            break
        default: break
        }
        
        foundCharacters = ""
    }
    
    func removeLiveBreaks(_ line:String) -> String {
        var newLine = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        newLine = newLine.replacingOccurrences(of: "\n", with: " ")
        return newLine
    }
}
