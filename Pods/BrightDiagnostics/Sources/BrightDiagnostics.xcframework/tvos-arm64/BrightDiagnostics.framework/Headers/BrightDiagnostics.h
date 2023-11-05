//
//  BrightDiagnostics.h
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

/// :nodoc: Project version number for BrightDiagnostics.
FOUNDATION_EXPORT double BrightDiagnosticsVersionNumber;

/// :nodoc: Project version string for BrightDiagnostics.
FOUNDATION_EXPORT const unsigned char BrightDiagnosticsVersionString[];

// In this header, import all the public headers of the framework using statements like #import <BrightDiagnostics/PublicHeader.h>
#import <BrightDiagnostics/BRTStream.h>
#import <BrightDiagnostics/BRTConfiguration.h>


/// Controls what data is collected
typedef NSString * BRTCollectedData NS_TYPED_ENUM;
/**
 Indicates device information will be collected
 
 @note *This setting is read-only, it is always on and may not be disabled*
 */
static BRTCollectedData const _Nonnull BRTCollectedDataDeviceInfo = @"com.att.mobile.bdsdk.deviceinfo";
/**
 Indicates application information will be collected
 
 @note *This setting is read-only, it is always on and may not be disabled*
 */
static BRTCollectedData const _Nonnull BRTCollectedDataApplicationInfo = @"com.att.mobile.bdsdk.applicationinfo";
/**
 Indicates location information will be collected if allowed by the user
 
 @note the user may disable location services in the privacy settings, or may grant either of *While in Use* or *Always* which may restrict the collection of location information, significant location change information and visit information
 */
static BRTCollectedData const _Nonnull BRTCollectedDataLocationInfo = @"com.att.mobile.bdsdk.locationinfo";
/**
 Indicates session information will be collected if available
 
 @note if the calling program does not use the default session information or provide the information with streaming information no session information will be collected by default
 */
static BRTCollectedData const _Nonnull BRTCollectedDataSessionInfo = @"com.att.mobile.bdsdk.sessioninfo";
/**
 Indicates stream information will be collected if available
 
 @note streaming information requires the calling program to submit information using the optional streaming API.  If no streaming API calls are made, no streaming information will be collected by default
 */
static BRTCollectedData const _Nonnull BRTCollectedDataStreamInfo = @"com.att.mobile.bdsdk.streaminfo";
/**
 Indicates advertising information will be collected if allowed by the user
 
 @note the user may disable advertising by enabling the *Limit Ad Tracking* privacy setting on the device
 */
static BRTCollectedData const _Nonnull BRTCollectedDataAdvertisingInfo = @"com.att.mobile.bdsdk.advertisinginfo";
/**
 Indicates cellular connection information will be collected
 
 @note *Not available on tvOS*
 */
static BRTCollectedData const _Nonnull BRTCollectedDataCellularInfo = @"com.att.mobile.bdsdk.cellularinfo";
/**
 Indicates WiFi connection information will be collected
 
 @note *Not available on tvOS*
 */
static BRTCollectedData const _Nonnull BRTCollectedDataWiFiInfo = @"com.att.mobile.bdsdk.wifiinfo";


/**
 The `BrightDiagnostics` API can be used via a single user entry point which
 will invoke a collection of diagnostic metrics and attempt to upload a
 package of information to the collection servers. This call should be placed
 at reasonable places within the calling application. Good places would be
 shortly after application launch, at points where the user is performing a
 function which identifies current location, at application close, and between
 sessions of whatever the calling program does, such as streaming events,
 downloading data, etc. The current SDK does not interact with the application
 user in any way. There are no pop-up screens or alert messages.
 
 Additional capabilities may be used by the calling application and may be
 enabled or disabled by individual API settings calls, via a configuration file,
 or by creating a configuration and calling the *configure* method for the
 configuration object.
 
 Each application scenario or engagement is controlled by an internal profile
 which determines how and when the data is packaged and uploaded to the collection
 servers.
 The optional configuration capabilities modify what data is allowed to be
 collected so the application can omit specific information which otherwise
 would be collected if allowed by the user privacy settings.
 */
@interface BrightDiagnostics : NSObject

/// The full name of the SDK
@property (nonatomic, readonly, class, nonnull) NSString *sdkName;

/// The current sdk version
@property (nonatomic, readonly, class, nonnull) NSString *sdkVersion;

/// The custom device ID
@property (nonatomic, class, nonnull) NSString *deviceID;

#pragma mark - Configuration

/**
 Enable / Disable data collection & uploads by the SDK.
 
 @note Any uploads already in progress will still complete
 when set to `false`.
 */
@property (nonatomic, class) BOOL enabled;

/**
 Set real-time data uploads on or off - defaults to off.
 
 This requests that uploads are performed immediately after collection,
 assuming we have a valid internet connection. If there is no current
 connection, the uploads are tried again at the next collection or when
 the application is paused, or about to terminate.
 
 When this is set to `NO`/`false`, data uploads are not performed in
 real-time immediately after data collection.  The data is buffered and
 is uploaded when the application starts, when the applicaion is paused
 or otherwise put in the background, and when the app is ready to be
 terminated.
 
 */
@property (nonatomic, class) BOOL realTimeUploadsEnabled;

/**
 typedef from CLLocation.h
 */
typedef double CLLocationAccuracy;

/**
 Sets the desired location accuracy to use for all subsequent location requests.
 The default value is `kCLLocationAccuracyBest`; using only as accurate value as
 you need will provide more efficient power usage.
 
 @note This value does not affect Significant Location Change based collection.
 */
@property (nonatomic, class) CLLocationAccuracy desiredLocationAccuracy;

/// The ISO country code currently checking for restrictions, or `nil` if no restrictions are enabled.
@property (nonatomic, readonly, class, nullable) NSString *countryCollectionRestriction;

/**
 Restrict all collection to **within** the specified country only.
 
 When enabled, collection will only occur if the device's current location is
 within the specified ISO country code. If the current location is unknown,
 no collection will occur. An empty string code is treated the same as a `nil` value.
 
 @note If the ISO country code you pass in is not valid, it will be assumed that the location
 is outside the country and no collection will occur. For valid ISO country codes, see
 [ISO 3166 Country Codes](https://www.iso.org/iso-3166-country-codes.html).
 
 @see `CountryCollectionRestrictionKey`
 
 @param countryCode The two-letter ISO country code. Any invalid characters (non-letter characters), or
 strings of less than two letters are considered invalid and the restriction will not be set (returning `NO`/`false`)
 
 @return `YES`/`true` if a code was set or `NO`/`false` if not
 */
+ (BOOL)restrictCollectionToCountryCode:(NSString *_Nullable)countryCode NS_SWIFT_NAME(restrictCollection(countryCode:));

/**
 Completion block for configureWithConfiguration
 */
typedef void (^ConfigureWithConfigurationCompletion)(BOOL);

/**
 Configure the SDK using a configuration object
 
 @param configuration  A BRTConfiguration object, use the builder pattern to build and configure one
 @param completion  A completion block that gets called with a boolean, representing true on success or false if the configuration could not be applied
 @note the completion block can be called on a different queue
 */
+ (void)configureWithConfiguration:(BRTConfiguration *_Nullable)configuration
                        completion:(ConfigureWithConfigurationCompletion _Nullable)completion;


#pragma mark - Collecting Data

/**
 Manually collect a set of metrics, and upload them to the collection server.
 */
+ (void)collect;

/**
 The specific items to be collected when calling `collect`. If not changed, a default set of data will be collected.
 
 @see `collectedInformation` for valid values.
 */
@property (nonatomic, class, nonnull) NSSet<BRTCollectedData> *collectedInformation;


#pragma mark - Time Based Triggers

/// Indicates if timer based collection is enabled
@property (nonatomic, readonly, class) BOOL timedCollectionEnabled;

/**
 Start timer based collection on the given time interval.
 
 Runs indefinitely until `+stopTimedCollection` is called. If
 a timed trigger was already started, it will be canceled and replaced
 with the new interval.
 
 @note Passing in a negative or zero time interval will be ignored.
 
 @param timeInterval The interval to collect.
 @return True on success, false if the timer could not be started
 */
+ (BOOL)startTimedCollectionWithTimeInterval:(NSTimeInterval)timeInterval NS_SWIFT_NAME(startTimedCollection(timeInterval:));

/** Stop timer based collection */
+ (void)stopTimedCollection;



@end
