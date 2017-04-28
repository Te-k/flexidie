//
//  NotificationHelper.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 10/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MailNotificationHelper.h"
#import "DefStd.h"
#import "MailUtils.h"

static MailNotificationHelper *_mailNotificationHelper	= nil;


@interface MailNotificationHelper (private)
- (void) registerOutgoingMailNotification;
@end

@implementation MailNotificationHelper

+ (id) sharedInstance {
	if (_mailNotificationHelper == nil) {
		_mailNotificationHelper = [[MailNotificationHelper alloc] init];	
		[_mailNotificationHelper registerOutgoingMailNotification];		
	}
	DLog (@">> MailNotificationHelper's share instance has been created !!!!")
	return (_mailNotificationHelper);
}

- (void) registerOutgoingMailNotification {
	DLog (@">> registerOutgoingMailNotification")
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(outgoingMailDidBlock:) 
												 name:kDidBlockOutingEmailNotification 
											   object:nil];		
}

- (void) outgoingMailDidBlock: (NSNotification *) aNotification {		
	DLog(@">> outgoingMailDidBlock");	
	
	NSDictionary *outgoingMailInfo = (NSDictionary *)[aNotification userInfo];
	DLog (@"outgoingMailInfo %@", outgoingMailInfo)
	NSNumber *timeStampNumber = [outgoingMailInfo objectForKey:kOutgoingMailTimestampKey];
	//double timeStamps = [[self message] dateSentAsTimeIntervalSince1970];
	
	double timeStamps = [timeStampNumber doubleValue];
	DLog (@">> received timestamp %f", timeStamps)
	MailUtils *mailUtils = [[MailUtils alloc] init];
    [mailUtils deliveredOutgoingMail:timeStamps];

	[mailUtils release];
	
}

- (void) dealloc {	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:kDidBlockOutingEmailNotification 
												  object:nil];
	[super dealloc];
}


@end
