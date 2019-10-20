//
//  WikiResult.swift
//  FillUps
//
//  Created by Keshav Bansal on 08/10/19.
//  Copyright © 2019 kb. All rights reserved.
//

import Foundation

class WikiResult: Codable {
    
    var query: WikiQuery?
    
    func getExtract() -> String? {
        return self.query?.pages?.first?.value.extract
    }
    
}

class WikiQuery: Codable {
    var pages: [String: WikiPage]?
}

class WikiPage: Codable {
    var pageid: Int?
    var ns: Int?
    var title: String?
    var extract: String?
}
