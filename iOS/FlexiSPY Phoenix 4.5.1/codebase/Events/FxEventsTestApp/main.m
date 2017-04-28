//
//  main.m
//  FxEventsTestApp
//
//  Created by Benjawan Tanarattanakorn on 9/30/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FxCallLogEvent.h"
#import "FxMmsEvent.h"
#import "FxLocationEvent.h"
#import "FxSmsEvent.h"
#import "FxRecipient.h"

#import "StringTestClass.h"

void testFunction()
{
	NSMutableArray* nsMutableArray = [[NSMutableArray alloc] init];
	NSObject* nsObject = [[NSObject alloc] init];
	
	@try {
		[nsObject hi];
	}
	@catch (NSException * e) {
		NSLog(@"Exception: %@", e);
	}
	@finally {
		NSLog(@"Finally un catch exception");
	}
	
	[nsMutableArray addObject:nsObject];
	[nsMutableArray addObject:nsObject];
	[nsMutableArray addObject:nsObject];
	[nsMutableArray addObject:nsObject];
	[nsObject release];
	[nsMutableArray release];
	
	FxSmsEvent* fxsmsEvent = [[FxSmsEvent alloc] init];
	[fxsmsEvent release];
	
	FxMmsEvent* fxMmsEvent = [[FxMmsEvent alloc] init];
	fxMmsEvent.subject = @"This is subject of MMS";
	fxMmsEvent.message = @"This is message body of MMS";
	[fxMmsEvent release];
}

void testEvent()
{
	FxLocationEvent* locationEvent = [[FxLocationEvent alloc] init];
	locationEvent.dateTime = @"2011-09-09 11:11:01";
	[locationEvent release];
}

void testStringClass()
{
	StringTestClass* stringTest = [[StringTestClass alloc] init];
	NSLog(stringTest.hello);
	NSLog(@"stringTest Length is: %d", [stringTest.hello length]);
	
	
	//	int* i = nil;
	//	NSLog(@"i %d", *i);
	
	if (stringTest.hello == NULL)
	{
		NSLog(@"stringTest is NULL");
	}
	else
	{
		NSLog(@"stringTest is not NULL");
	}
	
	[stringTest release];
}



int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    // int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;	
	
	//testFunction();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testEvent();
	testStringClass();
	
	FxCallLogEvent* fxEventCallLog	= [[FxCallLogEvent alloc] init];
	FxEventType eventType			= fxEventCallLog.eventType;
	fxEventCallLog.duration			= 4;
	
	// Error because it's readonly property
	//fxEventCallLog.eventType = kEventTypeSms;
	
	if (eventType == kEventTypeCallLog)
	{
		NSLog(@"kEventTypeCallLog is correct");
	}
	
	if ([fxEventCallLog.dateTime length] == 0)
	{
		NSLog(@"dateTime is correct");
	}else
	{
		NSLog(@"The string length is incorrect");
	}
	
	if ([fxEventCallLog.contactName length] == 0)
	{
		NSLog(@"contactName is correct");
	}else
	{
		NSLog(@"The string length is incorrect");
	}
	
	if ([fxEventCallLog.contactNumber length] == 0)
	{
		NSLog(@"contactNumber is correct");
	}else
	{
		NSLog(@"The string length is incorrect");
	}
	
	fxEventCallLog.dateTime = @"11:11:11 2011-08-24";
	if ([fxEventCallLog.dateTime length] == 19)
	{
		NSLog(@"dateTime is correct: %@", fxEventCallLog.dateTime);
	}else
	{
		NSLog(@"dateTime is incorrect");
	}
	
	[fxEventCallLog release];
	
	FxSmsEvent* fxsmsEvent		= [[FxSmsEvent alloc] init];
	FxRecipient* recipient		= [[FxRecipient alloc] init];
	recipient.recipContactName	= @"Mr. Hello";
	recipient.recipNumAddr		= @"forum.this@gmail.com";
	[fxsmsEvent addRecipient: recipient];
	[recipient release];
	
	recipient					= [[FxRecipient alloc] init];
	recipient.recipContactName	= @"Mr. Hi";
	recipient.recipNumAddr		= @"mindpath@ovi.com";
	[fxsmsEvent addRecipient: recipient];
	[recipient release];
	
	const NSMutableArray* recipientArray	= [fxsmsEvent recipientArray];
	int countRecipient						= [recipientArray count];
	int i;
	for (i = 0; i < countRecipient; i++)
	{
		recipient = [recipientArray objectAtIndex:i];
		NSLog(@"Recipient %i, ContactName: %@, Email: %@", i, [recipient recipContactName], [recipient recipNumAddr]);
	}
	[fxsmsEvent release];
	
	
    [pool release];
    return retVal;
}
