//
//  Globals.swift
//  WarnerMedia Privacy Test App
//
//  Created by Taylor Carr on 10/4/21.
//  Copyright © 2021 T Carr. All rights reserved.
//

import Foundation

// let languages: [String:String] = ["Arabic": "ar", "Bulgarian":"bg", "Croatian":"hr", "Czech":"cz", "Danish":"da", "Dutch":"nl", "English":"en-US", "Finnish":"fi", "French":"fr", "German":"de", "Hungarian":"hu", "Italian":"it", "Norwegian":"no", "Polish":"pl", "Portuguese (Brazil)":"pr-BR", "Portuguese (Portugal)":"pt", "Romanian":"ro", "Russian":"ru", "Slovak":"sk", "Slovenian": "sl", "Spanish (EU)":"es", "Spanish (LatAm)":"es-MX", "Swedish":"sv", "Turkish":"tr"]

struct Language: Hashable, Codable, Identifiable {
    var id = UUID()
    var language: String
    var abbreviation: String
    var isFavorite: Bool
}

struct languageMapStruct: Identifiable {
    var language: String
    var id: String { language }
    var details: languageDetails
}

// struct languageDetails: Hashable, Codable, Identifiable {
//    var language: String
//    var id: String { language }
//    var code: String
//    var isFavorite: Bool
// }

struct languageDetails: Hashable, Codable, Identifiable {
//    var language: String
//    var id: String { language }
    var id = UUID()
    var code: String
    var isFavorite: Bool
}

let languagesMap: [String: languageDetails] = defaults.object(forKey: "languagesMap") as? [String: languageDetails] ?? ["Arabic": languageDetails(code: "ar", isFavorite: false), "Bulgarian": languageDetails(code: "bg", isFavorite: false), "Croatian": languageDetails(code: "hr", isFavorite: false), "Czech": languageDetails(code: "cz", isFavorite: false), "Danish": languageDetails(code: "da", isFavorite: false), "Dutch": languageDetails(code: "nl", isFavorite: false), "English": languageDetails(code: "en-US", isFavorite: true), "Finnish": languageDetails(code: "fi", isFavorite: false), "French": languageDetails(code: "fr", isFavorite: false), "German": languageDetails(code: "de", isFavorite: false), "Hungarian": languageDetails(code: "hu", isFavorite: false), "Italian": languageDetails(code: "it", isFavorite: false), "Norwegian": languageDetails(code: "no", isFavorite: false), "Polish": languageDetails(code: "pl", isFavorite: false), "Portuguese (Brazil)": languageDetails(code: "pr-BR", isFavorite: false), "Portuguese (Portugal)": languageDetails(code: "pt", isFavorite: false), "Romanian": languageDetails(code: "ro", isFavorite: false), "Russian": languageDetails(code: "ru", isFavorite: false), "Slovak": languageDetails(code: "sk", isFavorite: false), "Slovenian": languageDetails(code: "sl", isFavorite: false), "Spanish (EU)": languageDetails(code: "es", isFavorite: false), "Spanish (LatAm)": languageDetails(code: "es-MX", isFavorite: false), "Swedish": languageDetails(code: "sv", isFavorite: false), "Turkish": languageDetails(code: "tr", isFavorite: false)]

// let languages3:[String:languageDetails] = ["English":languageDetails(code: "en-US", isFavorite: true)]

// let temp = languages3["English"]?.code
