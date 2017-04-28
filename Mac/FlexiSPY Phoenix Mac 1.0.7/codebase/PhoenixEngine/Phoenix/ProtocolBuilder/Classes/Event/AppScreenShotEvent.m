//
//  AppScreenShot.m
//  ProtocolBuilder
//
//  Created by ophat on 4/25/16.
//
//

#import "AppScreenShotEvent.h"

@implementation AppScreenShotEvent
@synthesize mUserLogonName, mApplicationID,mApplicationName,mTitle;
@synthesize mApplication_Catagory,mScreenshot_Catagory,mUrl,mMediaType,mScreenshotFilePath;

-(EventType)getEventType {
    #if TARGET_OS_IPHONE
    return APP_SCREEN_SHOT_MOBILE;
    #else
    return APP_SCREEN_SHOT;
    #endif
}

-(void)dealloc{
    [mUserLogonName release];
    [mApplicationID release];
    [mApplicationName release];
    [mTitle release];
    [mUrl release];
    [mScreenshotFilePath release];
    [super dealloc];
}

@end

