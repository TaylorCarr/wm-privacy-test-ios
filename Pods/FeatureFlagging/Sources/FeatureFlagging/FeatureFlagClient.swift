//
//  File.swift
//
//
//  Created by Dan Esrey on 4/1/20.
//

import Foundation

public class FeatureFlagClient {
    static let ffLibaryVersionCode = 1
    static let ffLibraryLanguage = "Swift"

    let minimumPollFrequencySeconds: Double = 60
    let storage = FeatureFlagStorage.shared

    var context: ClientConfiguration
    var activeConfig: LoadedConfiguraton?
    var fallbackConfig: FlagConfiguration?
    var featureFlagUserId = ""
    var ffLibraryVersionName: String?
    var timer: Timer?

    init(context: ClientConfiguration, config: FlagConfiguration?) {
        self.context = context

        if let localConfig = storage.getFlagConfigObjectFromDefaults() {
            activeConfig = LoadedConfiguraton(source: .cached, config: localConfig)
        } else if config != nil {
            activeConfig = LoadedConfiguraton(source: .fallback, config: config!)
            fallbackConfig = config
            storage.saveConfigToStorage(config!)
        }

        fetchRemoteConfig()

        let ffUserId = storage.get(key: .ffUserId) ?? storage.createUserId()
        featureFlagUserId = ffUserId

        let interval = setTimerInterval(with: context)

        startPollingTimer(with: interval)
        addSystemTargetingProperties()
    }

    static func createClient(with context: ClientConfiguration,
                             fallbackConfig: FlagConfiguration?,
                             completion: @escaping (Error?, FeatureFlagClient?) -> Void) throws
    {
        ConfigurationProvider.shared.checkForRemoteConfig(at: context.configUrl, version: ffLibaryVersionCode) { err, remoteConfig in
            guard err == nil else {
                // check for remote failed, so check local
                if let localConfig = FeatureFlagStorage.shared.loadLocalConfig() {
                    let client = FeatureFlagClient(context: context, config: localConfig)
                    client.fallbackConfig = fallbackConfig

                    print("\n\n\(FFClientError.noRemoteConfig)")

                    completion(nil, client)
                    return
                } else if let fallback = fallbackConfig {
                    let client = FeatureFlagClient(context: context, config: fallback)
                    client.fallbackConfig = fallbackConfig

                    print("\n\n\(FFClientError.noRemoteConfig)")

                    completion(nil, client)
                    return
                } else {
                    completion(FFClientError.missingConfig, nil)
                    return
                }
            }

            guard let config = remoteConfig else {
                completion(FFClientError.missingConfig, nil)
                return
            }

            let client = FeatureFlagClient(context: context, config: config)
            client.fallbackConfig = fallbackConfig
            completion(nil, client)
        }
    }

    func startPollingTimer(with interval: TimeInterval) {
        DispatchQueue.main.async {
            let timer1 = Timer(
                timeInterval: interval,
                target: self,
                selector: #selector(self.fetchRemoteConfig),
                userInfo: nil, repeats: true
            )

            timer1.tolerance = 5

            RunLoop.current.add(timer1, forMode: .default)

            self.timer = timer1
        }
    }

    @objc func fetchRemoteConfig() {
        ConfigurationProvider.shared.checkForRemoteConfig(at: context.configUrl, version: FeatureFlagClient.ffLibaryVersionCode) { _, remoteConfig in
            guard let config = remoteConfig else {
                return
            }
            self.updateConfig(config, source: .remote)
        }
    }

    public func queryAllFeatureFlags() throws -> [FlagQueryResult] {
        guard let activeConfig = activeConfig,
              !activeConfig.config.flags.isEmpty
        else {
            throw FFClientError.invalidConfig
        }

        var featureFlagResultsMap: [FlagQueryResult] = []
        let flagIds = activeConfig.config.flags.map { $0.id }

        for id in flagIds {
            if let result = try? queryFeatureFlag(flagId: id) {
                featureFlagResultsMap.append(result)
            }
        }

        return featureFlagResultsMap
    }

    private func queryFeatureFlag(featureId: String,
                                  activeConfig: LoadedConfiguraton,
                                  userId _: String?,
                                  ffUserId _: String,
                                  userTargeting _: [String: String]?,
                                  fallbackConfig: FlagConfiguration?) throws -> FlagQueryResult
    {
        var warnings = warningForActiveConfiguration(activeConfig: activeConfig)

        var flag = FlagEvaluator.shared.matchingFlagInConfiguration(featureId: featureId, configuration: activeConfig.config, warnings: &warnings)

        if flag == nil, activeConfig.source != .fallback, fallbackConfig != nil {
            flag = FlagEvaluator.shared.matchingFlagInConfiguration(
                featureId: featureId,
                configuration: fallbackConfig!,
                warnings: &warnings
            )

            warnings.append(Warning.FALLBACK_USED_FLAG_NOT_IN_REMOTE)
        }

        guard let foundFlag = flag else {
            throw flagNotFoundException(warnings: warnings)
        }

        var operationalId = context.userId
        var hashId = context.userId ?? UUID().uuidString
        var enabled = foundFlag.enabled
        var userIdType: String?
        var rolloutValue = 0
        var stickinessProperty: String?

        if let cohorts = foundFlag.cohorts,
           let cohortConfig = FlagEvaluator.shared.getCohortConfig(context: context, cohortConfigs: cohorts)
        {
            rolloutValue = cohortConfig.rolloutValue

            if let stickiness = cohortConfig.stickinessProperty {
                stickinessProperty = stickiness
            }
        } else {
            return FlagQueryResult(flagId: featureId, flagName: featureId, enabled: enabled, warnings: warnings, userId: nil, userIdType: userIdType)
        }
        // create the hash and 'user feature index' (derived from hash)
        if stickinessProperty == .ffUserId {
            operationalId = featureFlagUserId
            userIdType = .ffUserId
            hashId = featureFlagUserId
        }

        let salt = foundFlag.id

        guard let userFeatureIndex = try? FeatureIndexProvider.shared.getUserFeatureIndex(from: hashId, with: salt) else {
            return FlagQueryResult(flagId: foundFlag.id, flagName: foundFlag.name, enabled: enabled, warnings: warnings, userId: operationalId, userIdType: userIdType)
        }

        // determine whether or not flag is enabled for the given user
        if let index = Int(userFeatureIndex, radix: 10),
           let percentageRollout = Int(String(rolloutValue), radix: 10)
        {
            enabled = index < percentageRollout
        }

        return FlagQueryResult(flagId: foundFlag.id, flagName: foundFlag.name, enabled: enabled, warnings: warnings, userId: operationalId, userIdType: userIdType)
    }

    public func queryFeatureFlag(flagId: String) throws -> FlagQueryResult {
        guard let activeConfig = activeConfig, !activeConfig.config.flags.isEmpty else {
            throw FFClientError.invalidConfig
        }

        return try queryFeatureFlag(
            featureId: flagId,
            activeConfig: activeConfig,
            userId: context.userId,
            ffUserId: featureFlagUserId,
            userTargeting: context.targetingProperties,
            fallbackConfig: fallbackConfig
        )
    }

    func warningForActiveConfiguration(activeConfig: LoadedConfiguraton) -> [Warning] {
        var warnings = [Warning]()

        if activeConfig.source == FlagConfigurationSource.cached {
            warnings.append(Warning.CACHE_USED)
        } else if activeConfig.source == FlagConfigurationSource.fallback {
            warnings.append(Warning.FALLBACK_USED_REMOTE_LOAD_FAILED)
        }

        return warnings
    }

    func flagNotFoundException(warnings: [Warning]) -> Error {
        if warnings.contains(Warning.FLAG_TYPE_NOT_SUPPORTED) {
            return FFClientError.flagTypeNotSupported
        } else {
            return FFClientError.flagNotFound
        }
    }

    func updateConfig(_ config: FlagConfiguration, source _: FlagConfigurationSource) {
        storage.saveConfigToStorage(config)
    }

    public func updateUserProperties(userId: String, userTargeting: [String: String], replaceAllUserTargeting: Bool) {
        context.userId = userId

        if replaceAllUserTargeting == true {
            context.targetingProperties = userTargeting
        } else {
            for (key, value) in userTargeting {
                // if targeting properties already contains value for key, replace value with new
                // if targeting properties does not contain value for key, add key-value pair to targeting properties
                context.targetingProperties[key] = value
            }
        }
    }

    public func addSystemTargetingProperties() {
        let systemTargeting: [String: String] = [
            .ffLibaryVersionCode: "\(FeatureFlagClient.ffLibaryVersionCode)",
            .ffLibraryLanguage: "\(FeatureFlagClient.ffLibraryLanguage)",
        ]

        for (key, value) in systemTargeting {
            context.targetingProperties[key] = value
        }
    }

    func setTimerInterval(with context: ClientConfiguration) -> Double {
        return context.configPollingInterval > minimumPollFrequencySeconds ? context.configPollingInterval : minimumPollFrequencySeconds
    }

    enum FFClientError: Error {
        case failedHashProcessing
        case flagNotFound
        case flagTypeNotSupported
        case invalidConfig
        case invalidContext
        case missingConfig
        case missingConfigUrl
        case missingUserId
        case noRemoteConfig
        case noCachedConfig
        case targetingError
    }
}
