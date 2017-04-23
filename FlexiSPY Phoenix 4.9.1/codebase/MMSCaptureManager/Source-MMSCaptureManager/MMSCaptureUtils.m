//
//  SMSUtils.m
//  SMSCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 2/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MMSCaptureUtils.h"
#import "FMDatabase.h"
#import "DefStd.h"
#import "FxMmsEvent.h"


static NSString * const kSelectMMSEventSql	= @"select group_id from message where date = '%d' and association_id = 0 and address = '%@'";
// sms info key
static NSString * const kMMSEventKey		= @"MMSEVENT";
static NSString * const kSenderNumberKey	= @"SENDERNUMBER";
static NSString * const kDateStringKey		= @"DATESTRING";
static NSString * const kMMSEventDelegate	= @"MMSEVENTDELEGATE";


@interface MMSCaptureUtils (private)
- (NSInteger)	queryGroupIDFromText: (NSString *) aText address: (NSString *) aAddress ;
- (void)		queryConversationIdAndDeliverEvent: (NSDictionary *) aSMSInfo;
@end

@implementation MMSCaptureUtils


- (void) queryConversationIdAndDeliverMMSEvent: (FxMmsEvent *) aMMSEvent
								  senderNumber: (NSString *) aSenderNumber
							 messageDateString: (NSString *) aMessageDateString
									   delgate: (id) aEventDelegate {
	DLog (@">>>>>>>>>>>> schedule perform selector")	
	[self performSelector:@selector(queryConversationIdAndDeliverEvent:) 
			   withObject:[NSDictionary dictionaryWithObjectsAndKeys:
						   aMMSEvent,			kMMSEventKey, 
						   aSenderNumber,		kSenderNumberKey, 
						   aMessageDateString,	kDateStringKey,
						   aEventDelegate,		kMMSEventDelegate, nil] 
			   afterDelay:5];
	
}

- (NSInteger) queryGroupIDFromDate: (NSString *) aDateString address: (NSString *) aAddress {	
//- (NSInteger) queryGroupIDFromText: (NSString *) aText address: (NSString *) aAddress {	
	// -- find converstaion id if it doesn't exist for ios 5	
	FMDatabase *smsDatabase = [[FMDatabase databaseWithPath:kSMSHistoryDatabasePath] retain];
	[smsDatabase open];				
	NSString *sql			= [NSString stringWithFormat:kSelectMMSEventSql, [aDateString intValue], aAddress];
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

- (void) queryConversationIdAndDeliverEvent: (NSDictionary *) aMMSInfo {
	FxMmsEvent *mmsEvent		= [aMMSInfo objectForKey:kMMSEventKey];					// sms event
	NSString *senderNumber		= [aMMSInfo objectForKey:kSenderNumberKey];				// sender
	NSString *messageDateString = [aMMSInfo objectForKey:kDateStringKey];				// date
	id eventDelegate			= [aMMSInfo objectForKey:kMMSEventDelegate];			// event delegate
	
	DLog (@">>>>>>>>>>>>>>>>>> mms event %@", mmsEvent)
	NSInteger groupid = [self queryGroupIDFromDate:messageDateString
										   address:senderNumber];				
	if (groupid != 0) {
		[mmsEvent setMConversationID:[NSString stringWithFormat:@"%d", groupid]];
	}											
	DLog (@"Sender Number:%@",[mmsEvent senderNumber]);
	DLog (@"MMS conversation id:%@",[mmsEvent mConversationID]);
	
	[eventDelegate performSelector:@selector(eventFinished:) withObject:mmsEvent withObject:self];
}

@end
