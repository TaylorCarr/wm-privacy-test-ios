//
//  File.swift
//  
//
//  Created by Nirvan Nagar on 5/16/20.
//

import Foundation

class LoggingService {
    
    private let UNKNOWN = "Unknown"
    
    // TODO Find a real logging library to log messages with
    // private let actualLoggingLibrary: SomeLoggingLibrary
    private let network: NetworkHelper
    private let userDefaults: UserDefaultsManager
    private let deviceInfoService: DeviceInfoService
    private let appConfig: AppConfig

    init(network: NetworkHelper, userDefaults: UserDefaultsManager, deviceInfoService: DeviceInfoService, appConfig: AppConfig) {
        // TODO initialize the real logging library when we integrate one with psm
        //actualLoggingLibrary = LoggingLibrary()
        
        self.network = network
        self.userDefaults = userDefaults
        self.deviceInfoService = deviceInfoService
        self.appConfig = appConfig
    }

    func debug(message: String) {
        log(message: message)
    }
    
    func info(message: String) {
        log(message: message)
    }
    
    func warn(message: String) {
        log(message: message)
    }
    
    func error(message: String, logInfo: LogInfo) {
        log(message: message)
        
        let remainingErrorInfo = getRemainingErrorInfo()
        let errorLogEvent = ErrorLogEventMessage(
            eventType: logInfo.eventType,
            method: logInfo.method,
            WMUKID: remainingErrorInfo.wmUkId ?? UNKNOWN,
            brand: remainingErrorInfo.brand ?? UNKNOWN,
            platform: remainingErrorInfo.platform,
            error: true,
            errorMessage: message,
            flagName: logInfo.flagName,
            enabled: logInfo.flagEnabled,
            subBrand: remainingErrorInfo.subBrand ?? UNKNOWN
        )
        
        sendErrorLog(message: message, errorLogEventMessage: errorLogEvent)
    }

    private func log(message: String) {
        if appConfig.environment == .DEV || appConfig.environment == .TEST {
            print("Psm log: \(message)")
        } else {
            // TODO when we integrate a real logging library, log with it.
            // actualLoggingLibrary.log(level: level, message: message)
        }
    }
    
    func getRemainingErrorInfo() -> (wmUkId: String?, brand: String?, platform: String, subBrand: String?) {
        let wmUkId = userDefaults.getStringValue(forKey: .WMUKID)
        let platform = deviceInfoService.getDeviceInfo().osName
        
        guard let psmAppData = userDefaults.getObjectValue(forKey: .PsmApp) as? Data else {
            // This would never happen since the PsmApp should always be saved on the init of Psm
            return (wmUkId, nil, platform, nil)
        }
        
        do {
            let psmApp = try JSONDecoder().decode(PsmApp.self, from: psmAppData)
            return (wmUkId, psmApp.brand, platform, psmApp.subBrand)
        } catch {
            // This would never happen since the PsmApp should always be saved on the init of Psm
            return (wmUkId, nil, platform, nil)
        }
    }

    private func sendErrorLog(message: String, errorLogEventMessage: ErrorLogEventMessage) {
        let errorEvent = ErrorLogEvent(message: errorLogEventMessage)
        
        do {
            let requestBody = try JSONEncoder().encode(errorEvent)
            
            network.post(appConfig.errorLoggingEndpoint, body: requestBody) { (data, error) in
                if let error = error {
                    self.log(message: "Error when sending the error logs to the remote endpoint. Error: \(error)")
                } else {
                    self.log(message: "Successfully sent error to \(self.appConfig.errorLoggingEndpoint).")
                }
            }
        } catch {
            // This should never happen since we control the model of the error event and we would catch this with testin.
            log(message: "Error when sending the error logs to the remote endpoint. Error: \(error.localizedDescription)")
        }
    }
}
