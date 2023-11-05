//
//  BRTStream.h
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

/// Stream events
typedef NS_ENUM(NSInteger, BRTStreamEvent) {
    /// Started playing the multimedia to the user.
    BRTStreamEventPlaybackStart,
    /// Finished playing the multimedia to the user, independent of cause, including exiting media player.
    BRTStreamEventPlaybackEnd,
    /// User paused playback.
    BRTStreamEventPlaybackPause,
    /// User requested stopping playback. Shall be sent when the user presses stop, presses the back button, selects a new media stream to play, or exits the media player while still playing.
    BRTStreamEventPlaybackStop,
    /// User resumed playback.
    BRTStreamEventPlaybackResume,
    /// User started rewinding.
    BRTStreamEventPlaybackRewind,
    /// User started fast-forwarding.
    BRTStreamEventPlaybackFastForward,
    /// Opening animation is being shown to the user prior to playback starting.
    BRTStreamEventPreroll,
    /// Playback paused for buffering.
    BRTStreamEventBufferingBegan,
    /// Playback resumed after buffering.
    BRTStreamEventBufferingEnded,
    
};

/// BRTStreamLaunchType
typedef NS_ENUM(NSInteger, BRTStreamLaunchType) {
    /// Stream was launched by user selection
    BRTStreamLaunchTypeUserInitiated,
    /// Player launched the stream automatically following playback of another stream
    BRTStreamLaunchTypeAutoPlay,
    /// Cause of launch is not known -- should not be used, initiate development of new reason
    BRTStreamLaunchTypeUnknown
};

/// BRTStreamContentType
typedef NS_ENUM(NSInteger, BRTStreamContentType) {
    /// Stream Video content as Live
    BRTStreamContentTypeLive,
    /// Stream Video content as On Demand
    BRTStreamContentTypeVOD,
    /// Video content as DVR (including cDVR and mDVR)
    /// cDVR/mDVR stands for cloud/mobile digital video recording
    BRTStreamContentTypeRecorded,
    /// Stream Video content is Unknown
    BRTStreamContentTypeUnknown
};

/**
 
 */
@interface BRTStream : NSObject

/// Stream ID
@property (nonatomic, strong, readonly) NSString * _Nonnull streamID;

/// Current session
@property (nonatomic, strong, readonly) NSString * _Nullable session;

/// Account ID
@property (nonatomic, strong, readonly) NSString * _Nullable accountID;

/// User ID
@property (nonatomic, strong, readonly) NSString * _Nullable userID;

/// Requested bit rate
@property (nonatomic) float requestedBitRate;

/// Actual bit rate. Update this property as the stream begins playback.
@property (nonatomic) float actualBitRate;

/// launchType.
@property (nonatomic) BRTStreamLaunchType launchType;

/// ContentType.
@property (nonatomic) BRTStreamContentType contentType;


#pragma mark - Class Methods

#pragma mark Default properties

/**
 Set default properties to be used for Applications.
 
 Any collect call will use these properties by default. When set, they are not required to be passed in when creating new instances.
 
 @param session Current app session ID
 @param account Current app Account ID
 @param user Current app User ID
 */
+ (void)setDefaultPropertiesWithSession:(NSString *_Nullable)session
                                account:(NSString *_Nullable)account
                                   user:(NSString *_Nullable)user
NS_SWIFT_NAME(setDefaultProperties(session:account:user:));

/**
 Clear the default properties to be used by application.
 
 Any collect call will provide null strings for these values when cleared, until they are modified via the setDefaultProperties call.
 */
+ (void)clearDefaultProperties;


#pragma mark Creating Stream Objects

/**
 Create a new stream object.
 
 The `session`, `userID`, and `accountID` will be cached for future use.
 These values may be `nil` once set here or if already set.
 
 @param streamID The stream ID
 @param requestedBitRate The requested bitrate/quality for the stream
 @param session The current session
 @param userID The user ID
 @param accountID The account ID
 @return A new stream object
 */
+ (instancetype _Nonnull )streamWithStreamID:(NSString *_Nonnull)streamID requestedBitRate:(float)requestedBitRate session:(NSString *_Nullable)session accountID:(NSString *_Nullable)accountID userID:(NSString *_Nullable)userID;


/**
 Create a new stream object, using cached values for `session` `userID` `accountID`.
 
 @note The `session`, `userID` and `accountID` values must already be set
 or previously created via a `BRTStream` object), otherwise
 this method returns `nil` in these values.
 
 @param streamID The stream ID
 @param requestedBitRate The requested bitrate/quality for the stream
 @return A new stream object using cached values for session, accountID and userID
 */
+ (instancetype _Nonnull )streamWithStreamID:(NSString *_Nonnull)streamID requestedBitRate:(float)requestedBitRate;


#pragma mark - Instance Methods

#pragma mark Recording Stream Events & Playback

/**
 Record that the stream is loaded and ready to play
 
 @param actualBitrate The actual bitrate
 @param contentNetwork The content network
 */
- (void)readyToPlayWithActualBitrate:(float)actualBitrate contentNetwork:(NSString *_Nonnull)contentNetwork
NS_SWIFT_NAME(readyToPlay(actualBitrate:contentNetwork:));

/**
 Record a streaming event occured.
 
 @param event A streaming event.
 */
- (void)recordEvent:(BRTStreamEvent)event
NS_SWIFT_NAME(record(event:));

/**
 Record a streaming error has occured.
 
 @note For fatal errors which cause streaming to end, use `-finishWithError:` instead.
 
 @param error An error that has occured during playback.
 */
- (void)recordError:(NSString *_Nonnull)error
NS_SWIFT_NAME(record(error:));

#pragma mark Ending Streams

/**
 Report that the stream has ended.
 
 @param error Any fatal error that caused the stream to end.
 */
- (void)finishWithError:(NSString *_Nullable)error
NS_SWIFT_NAME(finish(error:));

/**
 Report that the stream is finished playing.
 */
- (void)finish;

@end
