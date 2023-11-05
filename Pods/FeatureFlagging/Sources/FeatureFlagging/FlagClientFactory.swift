//
//  File.swift
//
//
//  Created by Dan Esrey on 5/12/20.
//

import Foundation

public struct FlagClientFactory {
    public static let shared = FlagClientFactory()

    init() {}

    /**
     Creates a FeatureFlagClient after completing an async network request to retrieve the latest flag configuration

     If the network request fails, and a locally cached flag config exists, that will be used. If a locally stored flag config is unavailable, the fallback config will be used if provided.

     - Parameters:
        -   clientConfig: configuration of the FeatureFlagClient
        -   fallbackConfig:     used when remote and locally cached flag configurations are unavailable. It is highly recommended you provide this. If remote or cache is unavailable and you do not provide a fallback, a exception will be thrown.
        -   completion:     closure called with initialized FeatureFlagClient once call for remote flag config returns

     -  Throws: some error if the client is unable to load configuration from cache or remote and no fallbackConfig is provided.
     */
    public func createClient(clientConfig: ClientConfiguration,
                             fallbackConfig: FlagConfiguration?,
                             completion: @escaping (FeatureFlagClient) -> Void) throws
    {
        try? FeatureFlagClient.createClient(with: clientConfig,
                                            fallbackConfig: fallbackConfig,
                                            completion: { _, client in
                                                if let client = client {
                                                    completion(client)
                                                }
                                            })
    }

    /**
     Creates a FeatureFlagClient

     Once the client is initialized, the client initiates an async network request to retrieve the latest flag configuration. Because we return the client before the network call completes, the fallbackConfig parameter is required as that will always be used for flag configuration on first create (of a fresh install or data clearing). On future app runs, the locally cached flag configuration will be the active config for this client while the network call completes.

     - Parameters:
        -   clientConfig: configuration of the FeatureFlagClient
        -   fallbackConfig: used when remote and locally cached flag configurations are unavailable

     - Returns: initialized FeatureFlagClient
     */
    public func createClientAsyncRemote(clientConfig: ClientConfiguration,
                                        fallbackConfig: FlagConfiguration) -> FeatureFlagClient
    {
        return FeatureFlagClient(context: clientConfig, config: fallbackConfig)
    }
}
