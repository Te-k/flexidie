//
//  MailUtils.h
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 10/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EmailUtils : NSObject {
@private
	BOOL		mIsBlockOutgoingMailAlert;
//	NSTimer		*mWatchdogTimer;
	NSDate		*mBlockDateTime;
}

// -- This state is for one attermpt of outgoing email sendign, so this need to be reset after user try to send an outgoing email
@property (nonatomic, assign) BOOL mIsBlockOutgoingMailAlert;		
//@property (nonatomic, retain) NSTimer		*mWatchdogTimer;	
@property (nonatomic, retain) NSDate		*mBlockDateTime;	

// -- outgoing part
+ (id) sharedInstance;
+ (void) postNotificationForOutgoingBlockedMailWithTimestamp: (NSNumber *) aTimeStamp;

- (void) setReferenceTimeForDeleteUnsentEmail;
- (BOOL) blockOutgoingMail: (id) aMessageDelivery;
- (void) deleteUnsentMailAndExitApplication;


// -- incoming part

- (BOOL) blockIncomingMail: (id) aMailMessage
				   headers: (id) aMessageHeaders;

@end
