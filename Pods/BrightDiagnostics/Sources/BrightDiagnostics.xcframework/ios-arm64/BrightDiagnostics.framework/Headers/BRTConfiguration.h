//
//  BRTConfiguration.h
//  Public API
//
// **********************************************************************************
// *                                                                                *
// *    Copyright (c) 2019 AT&T Intellectual Property. ALL RIGHTS RESERVED          *
// *                                                                                *
// *    This code is licensed under a personal license granted to you by AT&T.      *
// *                                                                                *
// *    All use must comply with the terms of such license. No unauthorized use,    *
// *    copying, modifying or transfer is permitted without the express permission  *
// *    of AT&T. If you do not have a copy of the license, you may obtain a copy    *
// *    of such license from AT&T.                                                  *
// *                                                                                *
// **********************************************************************************
//

#import <Foundation/Foundation.h>

/**
 The BRTConfiguration class contains the  builder pattern implementation.
 It generates a configuration class that is consumed by the configureWithConfiguration: completion: API from BrightDiagnostics
 */
@interface BRTConfiguration : NSObject

/**
 Convenience method to return a  default configuration object for use with the builder pattern style
 of creating and updating a complex configuration object
 @note the default values are mentioned for each property presented below
 @return a preset default cofiguration object
 */
+ (instancetype _Nonnull)defaultConfiguration;

#pragma mark - Builder pattern configuration options

/**
 Update the configuration instance with the RealTimeUploads setting
 @return updated instance
 */
- (instancetype _Nonnull)withRealTimeUploads:(BOOL)enable;
/**
 The RealTimeUploads setting. Default is NO, realtime uploads disabled
 */
@property (nonatomic, readonly) BOOL realTimeUploads;

/**
 typedef from CLLocation.h
 */
typedef double CLLocationAccuracy;

/**
 Update the configuration instance with the DesiredLocationAccuracy setting
 @return updated instance
 */
- (instancetype _Nonnull)withDesiredLocationAccuracy:(CLLocationAccuracy)accuracy;
/**
 The DesiredLocationAccuracy setting. Default is kCLLocationAccuracyBest.
 */
@property (nonatomic, readonly) CLLocationAccuracy desiredLocationAccuracy;

/**
 Update the configuration instance with the IntervalTimer setting.
 Any non-zero value enables a timer to periodically call the collect() function
 @return updated instance
 */
- (instancetype _Nonnull)withTimeInterval:(NSTimeInterval)timeInterval;
/**
The current IntervalTimer setting. Default is 0, disabled.
 */
@property (nonatomic, readonly) NSTimeInterval timeInterval;

/**
 Update the configuration instance with the Country Restriction setting. Set to the null string or nil if no restriction.
 @param countryCollectionRestriction - String value of 2-character ISO country code to restrict collection by country
 @return updated instance
 */
- (instancetype _Nonnull)withCountryCollectionRestriction:(NSString *_Nullable)countryCollectionRestriction;
/**
 The current country collection restriction. Value is a 2-character ISO country code. Default is nill, NO restriction.
 [ISO 3166 Country Codes](https://www.iso.org/iso-3166-country-codes.html).
 */
@property (nonatomic, readonly) NSString *_Nullable countryCollectionRestriction;

/**
 Update the configuration instance with the DeviceId setting.
 @param deviceId - String value of deviceId
 @return updated instance
 */
- (instancetype _Nonnull)withDeviceId:(NSString *_Nullable)deviceId;
/**
 The current deviceID/CustomID Value set by Hosting App. Default is nill.
 */
@property (nonatomic, readonly) NSString *_Nullable deviceID;


#pragma mark - Builder pattern data collection settings

/**
 Update the configuration instance with the CollectDataLocationInfo setting.
 @param enable - BOOL value to enable or disable the setting
 @return updated instance
 */
- (instancetype _Nonnull)withDataLocationInfo:(BOOL)enable;
/**
 The CollectDataLocationInfo setting. Default is YES, enabled.
 */
@property (nonatomic, readonly) BOOL collectDataLocationInfo;

/**
 Update the configuration instance with the CollectDataSessionInfo setting.
 @param enable - BOOL value to enable or disable the setting
 @return updated instance
 */
- (instancetype _Nonnull)withDataSessionInfo:(BOOL)enable;
/**
 Tthe CollectDataSessionInfo setting. Default is NO, disabled.
 */
@property (nonatomic, readonly) BOOL collectDataSessionInfo;

/**
 Update the configuration instance with the CollectDataStreamInfo setting.
 @param enable - BOOL value to enable or disable the setting
 @return updated instance
 */
- (instancetype _Nonnull)withDataStreamInfo:(BOOL)enable;
/**
 Tthe CollectDataStreamInfo setting. Default is NO, disabled.
 */
@property (nonatomic, readonly) BOOL collectDataStreamInfo;

/**
 Update the configuration instance with the CollectDataAdvertisingInfo setting.
 @param enable - BOOL value to enable or disable the setting
 @return updated instance
 */
- (instancetype _Nonnull)withDataAdvertisingInfo:(BOOL)enable;
/**
 Tthe CollectDataAdvertisingInfo setting. Default is YES, enabled.
 */
@property (nonatomic, readonly) BOOL collectDataAdvertisingInfo;

#if !TARGET_OS_TV
/**
 Update the configuration instance with the CollectDataNetworkInfo setting
 @note Network Info enables or disabled both Cellular and WiFi info as available on the current platform
 @param enable - BOOL value to enable or disable the setting
 @return updated instance
 */
- (instancetype _Nonnull)withDataNetworkInfo:(BOOL)enable;
/**
 Tthe CollectDataNetworkInfo setting. Default is YES, enabled.
 */
@property (nonatomic, readonly) BOOL collectDataNetworkInfo;

/**
 Update the configuration instance with the CollectDataCellularInfo setting
 @note Cellular Info is unavailable on tvOS and the simulator, this setting is ignored on those platforms
 @param enable - BOOL value to enable or disable the setting
 @return updated instance
 */
- (instancetype _Nonnull)withDataCellularInfo:(BOOL)enable;
/**
 Tthe CollectDataCellularInfo setting. Default is YES, enabled.
 */
@property (nonatomic, readonly) BOOL collectDataCellularInfo;

/**
 Update the configuration instance with the CollectDataWiFiInfo setting.
 @note WiFi Data info is unavailable on tvOS and the simulator, this setting is ignored on those platforms
 @param enable - BOOL value to enable or disable the setting
 @return updated instance
 */
- (instancetype _Nonnull)withDataWiFiInfo:(BOOL)enable;
/**
 Tthe CollectDataWiFiInfo setting. Default is YES, enabled.
 */
@property (nonatomic, readonly) BOOL collectDataWiFiInfo;
#endif

@end
