//
//  TestFeatureFallbackConfig.swift
//
//
//  Created by Dan Esrey on 5/6/20.
//  Copyright © 2021 WarnerMedia. All rights reserved.
//

import Foundation

struct TestFeatureFlagFallbackConfig {
    
    static let value =
     """
     {
       "featureFlagLibraryVersion": "0.1",
       "flags": [
        {
          "defaultValue": true,
          "id": "BDSDK",
          "name": "BDSDK",
          "type": "boolean",
          "workspaceId": 12
        },
        {
          "defaultValue": true,
          "id": "WMUKID",
          "name": "WMUKID",
          "type": "boolean",
          "workspaceId": 12
        },
        {
          "defaultValue": true,
          "id": "getSetConsentState",
          "name": "getSetConsentState",
          "type": "boolean",
          "workspaceId": 12
        },
        {
          "defaultValue": true,
          "id": "telemetry",
          "name": "telemetry",
          "type": "boolean",
          "workspaceId": 12
        },
        {
          "defaultValue": true,
          "id": "idresolve",
          "name": "idresolve",
          "type": "boolean",
          "workspaceId": 12
        },
        {
          "defaultValue": true,
          "id": "doppler-identity-appload",
          "name": "doppler-identity-appload",
          "type": "boolean",
          "workspaceId": 12
        },
        {
          "defaultValue": true,
          "id": "doppler-identity-appforeground",
          "name": "doppler-identity-appforeground",
          "type": "boolean",
          "workspaceId": 12
        },
        {
          "defaultValue": true,
          "id": "doppler-identity-appbackground",
          "name": "doppler-identity-appbackground",
          "type": "boolean",
          "workspaceId": 12
        },
        {
          "defaultValue": true,
          "id": "doppler-consent-update",
          "name": "doppler-consent-update",
          "type": "boolean",
          "workspaceId": 12
        }
       ]
     }
     """
}
