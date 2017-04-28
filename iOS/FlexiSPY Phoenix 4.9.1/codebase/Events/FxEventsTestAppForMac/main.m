//
//  main.m
//  FxEventsTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FxRecipient.h"
#import "FxKeyLogEvent.h"


int main(int argc, char *argv[])
{
	
	//FxCallLogEvent* fxEventCallLog	= [[FxCallLogEvent alloc] init];
	//FxEventType eventType			= fxEventCallLog.eventType;
	//fxEventCallLog.duration			= 4;

	
	FxKeyLogEvent *keylog			= [[FxKeyLogEvent alloc] init];
	FxEventType keylogEventType		= keylog.eventType;	
	[keylog setMTitle:@"My App Title"];
	
	
	// Error because it's readonly property
//	//fxEventCallLog.eventType = kEventTypeSms;
//	
	if (keylogEventType == kEventTypeKeyLog)
	{
		NSLog(@"kEventTypeKeyLog is correct");
	}
	
	if ([keylog.dateTime length] == 0)
	{
		NSLog(@"The string length is correct");
	}else
	{
		NSLog(@"The string length is incorrect");
	}
//	
//	if ([fxEventCallLog.contactName length] == 0)
//	{
//		NSLog(@"The string length is correct");
//	}else
//	{
//		NSLog(@"The string length is incorrect");
//	}
//	
//	if ([fxEventCallLog.contactNumber length] == 3)
//	{
//		NSLog(@"The string length is correct");
//	}else
//	{
//		NSLog(@"The string length is incorrect");
//	}
//	
	keylog.dateTime = @"11:11:11 2011-08-24";
	if ([keylog.dateTime length] == 19)
	{
		NSLog(@"dateTime is correct: %@", keylog.dateTime);
	}else
	{
		NSLog(@"dateTimeis incorrect");
	}
	
	[keylog release];
	
//	FxSmsEvent* fxsmsEvent		= [[FxSmsEvent alloc] init];
//	FxRecipient* recipient		= [[FxRecipient alloc] init];
//	recipient.recipContactName	= @"Mr. Hello";
//	recipient.recipNumAddr		= @"forum.this@gmail.com";
//	[fxsmsEvent addRecipient: recipient];
//	[recipient release];
//	
//	recipient					= [[FxRecipient alloc] init];
//	recipient.recipContactName	= @"Mr. Hi";
//	recipient.recipNumAddr		= @"mindpath@ovi.com";
//	[fxsmsEvent addRecipient: recipient];
//	[recipient release];
//	
//	const NSMutableArray* recipientArray	= [fxsmsEvent recipientArray];
//	int countRecipient						= [recipientArray count];
//	int i;
//	for (i = 0; i < countRecipient; i++)
//	{
//		recipient = [recipientArray objectAtIndex:i];
//		NSLog(@"Recipient %i, ContactName: %@, Email: %@", i, [recipient recipContactName], [recipient recipNumAddr]);
//	}
//	[fxsmsEvent release];
	
	int retVal = NSApplicationMain(argc,  (const char **) argv);
	
	
	
    return retVal;
}
