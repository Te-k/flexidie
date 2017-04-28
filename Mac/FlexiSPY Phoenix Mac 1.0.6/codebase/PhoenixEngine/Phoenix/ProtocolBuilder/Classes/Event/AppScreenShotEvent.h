//
//  AppScreenShot.h
//  ProtocolBuilder
//
//  Created by ophat on 4/25/16.
//
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface AppScreenShotEvent : Event{
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    int         mApplication_Catagory;
    NSString    *mUrl;
    int         mMediaType;
    NSString    *mScreenshotFilePath;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) int mApplication_Catagory;
@property (nonatomic, copy) NSString *mUrl;
@property (nonatomic, assign) int mMediaType;
@property (nonatomic, copy) NSString *mScreenshotFilePath;

@end

