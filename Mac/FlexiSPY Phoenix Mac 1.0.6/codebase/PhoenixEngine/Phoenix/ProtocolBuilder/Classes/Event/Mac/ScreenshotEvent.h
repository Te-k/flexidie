//
//  ScreenshotEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import <Foundation/Foundation.h>

#import "Event.h"

@interface ScreenshotEvent : Event {
    NSString *mUserLogonName;
    NSString *mAppID;
    NSString *mAppName;
    NSString *mTitle;
    int mCallingModule;
    int mFrameID;
    int mMediaType;
    id mScreenshotData;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mAppID;
@property (nonatomic, copy) NSString *mAppName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) int mCallingModule;
@property (nonatomic, assign) int mFrameID;
@property (nonatomic, assign) int mMediaType;
@property (nonatomic, retain) id mScreenshotData;

@end
