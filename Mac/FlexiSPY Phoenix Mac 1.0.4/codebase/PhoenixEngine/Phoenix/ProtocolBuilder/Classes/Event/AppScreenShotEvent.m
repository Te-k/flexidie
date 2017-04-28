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
@synthesize mApplication_Catagory,mUrl,mMediaType,mScreenshotFilePath;

-(EventType)getEventType {
    return APP_SCREEN_SHOT;
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

