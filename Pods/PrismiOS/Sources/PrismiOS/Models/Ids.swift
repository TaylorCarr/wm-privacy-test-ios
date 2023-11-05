//
//  File.swift
//  
//
//  Created by Dan Esrey on 6/29/20.
//

import Foundation

struct Ids: Codable, Equatable {
    var kruxid: String?
    var ctv_id: String?
    var maid: String?
    
    init(kruxid: String? = nil, ctv_id: String? = nil, maid: String? = nil) {
        self.kruxid = kruxid
        self.ctv_id = ctv_id
        self.maid = maid
    }
}
