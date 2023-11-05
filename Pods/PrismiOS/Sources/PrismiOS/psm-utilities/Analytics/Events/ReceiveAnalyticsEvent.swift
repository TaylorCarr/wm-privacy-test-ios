//
//  ReceiveAnalyticsEvent.swift
//  
//
//  Created by Ungureanu Lucian on 27/04/2021.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//


enum ReceiveEventType: String {
    case privacy = "privacy"
    case identity = "identity"
}

enum ReceiveEventName: String {
    case consentUpdate = "consent update"
    case appLoad = "identity on app load"
    case appForeground = "identity on app foreground"
    case appBackground = "identity on app background"
}


class ReceiveAnalyticsEvent: AnalyticsEvent {
    let appId: String
    let platform: String
    let companyName: String
    let brand: String
    let subBrand: String
    let productName: String
    let wmukid: String
    let eventId: String
    let eventTimestamp: String
    let sentAtTimestamp: String
    
    let eventType: String
    let eventName: String
    
    let ids: ReceiveIds
    let device: Device
    let clientResolvedIp: String
    let location: ReceiveLocation
    let consentProperties: ConsentProperties
    let library: Library
    let eventProperties: EventProperties
    
    init(appId: String, platform: String, companyName: String, brand: String, subBrand: String, productName: String,
         wmukid: String, eventId: String, eventTimestamp: String, sentAtTimestamp: String,
         eventType: String, eventName: String,
         ids: ReceiveIds, device: Device, clientResolvedIp: String, location: ReceiveLocation,
         consentProperties: ConsentProperties, library: Library, eventProperties: EventProperties) {
        self.appId = appId
        self.platform = platform
        self.companyName = companyName
        self.brand = brand
        self.subBrand = subBrand
        self.productName = productName
        self.wmukid = wmukid
        self.eventId = eventId
        self.eventTimestamp = eventTimestamp
        self.sentAtTimestamp = sentAtTimestamp
        
        self.eventType = eventType
        self.eventName = eventName
        
        self.ids = ids
        self.device = device
        self.clientResolvedIp = clientResolvedIp
        self.location = location
        self.consentProperties = consentProperties
        self.library = library
        self.eventProperties = eventProperties
        
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           
           appId = try container.decode(String.self, forKey: .appId)
           platform = try container.decode(String.self, forKey: .platform)
           companyName = try container.decode(String.self, forKey: .companyName)
           brand = try container.decode(String.self, forKey: .brand)
           subBrand = try container.decode(String.self, forKey: .subBrand)
           productName = try container.decode(String.self, forKey: .productName)
           wmukid = try container.decode(String.self, forKey: .wmukid)
           eventId = try container.decode(String.self, forKey: .eventId)
           eventTimestamp = try container.decode(String.self, forKey: .eventTimestamp)
           sentAtTimestamp = try container.decode(String.self, forKey: .sentAtTimestamp)
           eventType = try container.decode(String.self, forKey: .eventType)
           eventName = try container.decode(String.self, forKey: .eventName)
           ids = try container.decode(ReceiveIds.self, forKey: .ids)
           device = try container.decode(Device.self, forKey: .device)
           clientResolvedIp = try container.decode(String.self, forKey: .clientResolvedIp)
           location = try container.decode(ReceiveLocation.self, forKey: .location)
           consentProperties = try container.decode(ConsentProperties.self, forKey: .consentProperties)
           library = try container.decode(Library.self, forKey: .library)
           eventProperties = try container.decode(EventProperties.self, forKey: .eventProperties)

           try super.init(from: decoder)
       }
       
       override func encode(to encoder: Encoder) throws {
           try super.encode(to: encoder)
           
           var container = encoder.container(keyedBy: CodingKeys.self)
           try container.encode(appId, forKey: .appId)
           try container.encode(platform, forKey: .platform)
           try container.encode(companyName, forKey: .companyName)
           try container.encode(brand, forKey: .brand)
           try container.encode(subBrand, forKey: .subBrand)
           try container.encode(productName, forKey: .productName)
           try container.encode(wmukid, forKey: .wmukid)
           try container.encode(eventId, forKey: .eventId)
           try container.encode(eventTimestamp, forKey: .eventTimestamp)
           try container.encode(sentAtTimestamp, forKey: .sentAtTimestamp)
           try container.encode(eventType, forKey: .eventType)
           try container.encode(eventName, forKey: .eventName)
           try container.encode(ids, forKey: .ids)
           try container.encode(device, forKey: .device)
           try container.encode(clientResolvedIp, forKey: .clientResolvedIp)
           try container.encode(location, forKey: .location)
           try container.encode(consentProperties, forKey: .consentProperties)
           try container.encode(library, forKey: .library)
           try container.encode(eventProperties, forKey: .eventProperties)
       }
       
    enum CodingKeys: String, CodingKey {
        case appId
        case platform
        case companyName
        case brand
        case subBrand
        case productName
        case wmukid
        case eventId
        case eventTimestamp
        case sentAtTimestamp
        case eventType
        case eventName
        case ids
        case device
        case clientResolvedIp
        case location
        case consentProperties
        case library
        case eventProperties
    }
}

extension ReceiveAnalyticsEvent: CustomStringConvertible {
    var description: String {
        return """
ReceiveAnalyticsEvent(appId: \(appId), platform: \(platform), companyName: \(companyName), brand: \(brand), subBrand: \(subBrand), productName: \(productName), wmukid: \(wmukid), eventId: \(eventId), eventTimestamp: \(eventTimestamp), sentAtTimestamp: \(sentAtTimestamp),
eventType: \(eventType), eventName: \(eventName),
ids: \(ids)), device: \(device), clientResolvedIp: \(clientResolvedIp), location: \(location), consentProperties: \(consentProperties), library: \(library),
eventProperties: \(eventProperties)
"""
    }
}

extension ReceiveAnalyticsEvent: Equatable {
    static func == (lhs: ReceiveAnalyticsEvent, rhs: ReceiveAnalyticsEvent) -> Bool {
        lhs.appId == rhs.appId
            && lhs.platform == rhs.platform
            && lhs.companyName == rhs.companyName
            && lhs.brand == rhs.brand
            && lhs.subBrand == rhs.subBrand
            && lhs.productName == rhs.productName
            && lhs.wmukid == rhs.wmukid
            && lhs.eventId == rhs.eventId
            && lhs.eventTimestamp == rhs.eventTimestamp
            && lhs.sentAtTimestamp == rhs.sentAtTimestamp
            
            && lhs.eventType == rhs.eventType
            && lhs.eventName == rhs.eventName
            
            && lhs.ids == rhs.ids
            && lhs.device == rhs.device
            && lhs.clientResolvedIp == rhs.clientResolvedIp
            && lhs.location == rhs.location
            && lhs.consentProperties == rhs.consentProperties
            && lhs.library == rhs.library
    }
}
