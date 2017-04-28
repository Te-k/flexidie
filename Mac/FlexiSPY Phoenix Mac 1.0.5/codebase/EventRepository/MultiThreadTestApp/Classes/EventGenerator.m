//
//  EventGenerator.m
//  MultiThreadTestApp
//
//  Created by Makara Khloth on 11/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventGenerator.h"
#import "FxCallLogEvent.h"
#import "FxSmsEvent.h"
#import "FxSystemEvent.h"
#import "FxEmailEvent.h"
#import "FxMmsEvent.h"
#import "FxSettingsEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"
#import "FxLocationEvent.h"
#import "FxPanicEvent.h"
#import "MediaEvent.h"
#import "ThumbnailEvent.h"
#import "FxGPSTag.h"
#import "FxCallTag.h"

#import "DAOFactory.h"
#import "CallLogDAO.h"

#import "EventRepositoryManager.h"
#import "EventQueryPriority.h"

@implementation EventGenerator

+ (void) generateEventAndInsertInDB: (EventRepositoryManager*) aEventRepositoryManager {
	NSInteger maxEvent = 10000;
	NSInteger maxNotGenerateEvent = 0;
	NSInteger i;
	
	NSString* const kEventDateTime  = @"20-10-2011 03:04:45";
	NSString* const kContactName    = @"Mr. Makara KHLOTH";
	NSString* const kContactNumber  = @"+66860843742";
	
	// Create call event
	// Call log
    for (i = 0; i < maxNotGenerateEvent; i++) {
		FxCallLogEvent* event = [[FxCallLogEvent alloc] init];
		event.dateTime = kEventDateTime;
		event.contactName = kContactName;
		event.contactNumber = kContactNumber;
		if (i % 2 == 0) {
			event.direction = kEventDirectionIn;
		} else {
			event.direction = kEventDirectionOut;
		}
		event.duration = i;
		[aEventRepositoryManager insert:event];
		[event release];
	}
	
	// Sms
	for (i = 0; i < maxNotGenerateEvent; i++) {
		FxSmsEvent* event = [[FxSmsEvent alloc] init];
		[event setDateTime:kEventDateTime];
		if (i % 2 == 0) {
			event.direction = kEventDirectionIn;
		} else {
			event.direction = kEventDirectionOut;
		}
		[event setSenderNumber:@"+85511773337"];
		[event setContactName:@"Mr. A and MR M'c B"];
		[event setSmsSubject:@"Hello B, introduction"];
		[event setSmsData: @"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
		 "Copyright 2004 Free Software Foundation, Inc."
		 "GDB is free software, covered by the GNU General 'Public License', and you are"
		 "welcome to change it and/or distribute copies of it under certain conditions."
		 "Type \"show copying\" to see the conditions."];
		
		// @todo back to test [add the same recipient object but change the value after added, and see what happen?]
		FxRecipient* recipient = [[FxRecipient alloc] init];
		[recipient setRecipContactName:@"Mr. Jame 007"];
		[recipient setRecipNumAddr:@"jame@porn.com"];
		[recipient setRecipType:kFxRecipientTO];
		[event addRecipient:recipient];
		[recipient release];
		recipient = [[FxRecipient alloc] init];
		[recipient setRecipContactName:@"Mr. Jame 069"];
		[recipient setRecipNumAddr:@"jame@pornxx.com"];
		[recipient setRecipType:kFxRecipientCC];
		[event addRecipient:recipient];
		[recipient release];
		
		[aEventRepositoryManager insert:event];
		[event release];
	}
	
	// MMS
	for (i = 0; i < maxNotGenerateEvent; i++) {
		FxMmsEvent* event = [[FxMmsEvent alloc] init];
		[event setDateTime:kEventDateTime];
		if (i % 2 == 0) {
			event.direction = kEventDirectionIn;
		} else {
			event.direction = kEventDirectionOut;
		}
		[event setSenderNumber:@"08608563286"];
		[event setSenderContactName:@"Mr. A and MR M'c B"];
		[event setSubject:@"Hello B, introduction"];
		[event setMessage:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
		 "Copyright 2004 Free Software Foundation, Inc."
		 "GDB is free software, covered by the GNU General Public License, and you are"
		 "welcome to change it and/or distribute copies of it under certain conditions."
		 "Type \"show copying\" to see the conditions."];
		
		FxAttachment* attachment = [[FxAttachment alloc] init];
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Sqlite3-Code" ofType:@"png"]; // Bundle/Sqlite3-Code.png
		[attachment setFullPath:filePath];
		[event addAttachment:attachment];
		[attachment release];
		
		// @todo back to test [add the same recipient object but change the value after added, and see what happen?]
		FxRecipient* recipient = [[FxRecipient alloc] init];
		[recipient setRecipContactName:@"Mr. Jame 007"];
		[recipient setRecipNumAddr:@"jame@porn.com"];
		[recipient setRecipType:kFxRecipientTO];
		[event addRecipient:recipient];
		[recipient release];
		recipient = [[FxRecipient alloc] init];
		[recipient setRecipContactName:@"Mr. Jame 069"];
		[recipient setRecipNumAddr:@"jame@pornxx.com"];
		[recipient setRecipType:kFxRecipientCC];
		[event addRecipient:recipient];
		[recipient release];
		[aEventRepositoryManager insert:event];
		[event release];
	}
	
	// Email
	for (i = 0; i < maxNotGenerateEvent; i++) {
		FxEmailEvent* event = [[FxEmailEvent alloc] init];
		[event setDateTime:kEventDateTime];
		if (i % 2 == 0) {
			event.direction = kEventDirectionIn;
		} else {
			event.direction = kEventDirectionOut;
		}
		[event setSenderEmail:@"helloworld@apple.com"];
		[event setSenderContactName:@"Mr. A and MR M'c B"];
		[event setSubject:@"Hello B, introduction"];
		[event setMessage:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
		 "Copyright 2004 Free Software Foundation, Inc."
		 "GDB is free software, covered by the GNU General Public License, and you are"
		 "welcome to change it and/or distribute copies of it under certain conditions."
		 "Type \"show copying\" to see the conditions."];
		[event setHtml:FALSE];
		
		FxAttachment* attachment = [[FxAttachment alloc] init];
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Sqlite3-Code" ofType:@"png"]; // Bundle/Sqlite3-Code.png
		[attachment setFullPath:filePath];
		[event addAttachment:attachment];
		[attachment release];
		
		// @todo back to test [add the same recipient object but change the value after added, and see what happen?]
		FxRecipient* recipient = [[FxRecipient alloc] init];
		[recipient setRecipContactName:@"Mr. Jame 007"];
		[recipient setRecipNumAddr:@"jame@porn.com"];
		[recipient setRecipType:kFxRecipientTO];
		[event addRecipient:recipient];
		[recipient release];
		recipient = [[FxRecipient alloc] init];
		[recipient setRecipContactName:@"Mr. Jame 069"];
		[recipient setRecipNumAddr:@"jame@pornxx.com"];
		[recipient setRecipType:kFxRecipientCC];
		[event addRecipient:recipient];
		[recipient release];
		[aEventRepositoryManager insert:event];
		[event release];
	}
	
	// Location
	for (i = 0; i < maxNotGenerateEvent; i++) {
		FxLocationEvent* event = [[FxLocationEvent alloc] init];
		event.dateTime = kEventDateTime;
		[event setLongitude:101.2384383];
		[event setLatitude:13.3847332];
		[event setAltitude:92.23784];
		[event setHorizontalAcc:0.3493];
		[event setVerticalAcc:0.87348];
		[event setSpeed:0.63527];
		[event setHeading:11.87];
		[event setDatumId:5];
		[event setNetworkId:@"512"];
		[event setNetworkName:@"DTAC"];
		[event setCellId:12211];
		[event setCellName:@"Paiyathai"];
		[event setAreaCode:@"12342"];
		[event setCountryCode:@"53"];
		[event setCallingModule:kGPSCallingModuleCoreTrigger];
		[event setMethod:kGPSTechAssisted];
		[event setProvider:kGPSProviderUnknown];
		[aEventRepositoryManager insert:event];
		[event release];
	}
	
	// System
	NSString* const kSystemMessage  = @"[4200 -1.00.1 03-05-2011][OK]\nCommand being process";
	for (i = 0; i < maxNotGenerateEvent; i++) {
		FxSystemEvent* event = [[FxSystemEvent alloc] init];
		[event setDateTime:kEventDateTime];
		if (i % 2 == 0) {
			[event setSystemEventType:kSystemEventTypeSmsCmd];
			event.direction = kEventDirectionIn;
		} else {
			event.direction = kEventDirectionOut;
			[event setSystemEventType:kSystemEventTypeSmsCmdReply];
		}
		[event setMessage:kSystemMessage];
		[aEventRepositoryManager insert:event];
		[event release];
	}
	
	// Panic status
	for (i = 0; i < maxNotGenerateEvent; i++) {
		FxPanicEvent* event = [[FxPanicEvent alloc] init];
		[event setDateTime:kEventDateTime];
		if (i % 2 == 0) {
			[event setPanicStatus:kFxPanicStatusStop];
		} else {
			[event setPanicStatus:kFxPanicStatusStart];
		}
		[aEventRepositoryManager insert:event];
		[event release];
	}
	
	// Panic image
	for (i = 0; i < maxNotGenerateEvent; i++) {
		MediaEvent* event = [[MediaEvent alloc] init];
		event.dateTime = kEventDateTime;
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Sqlite3-Code" ofType:@"png"]; // Bundle/Sqlite3-Code.png
		[event setFullPath:filePath];
		[event setEventType:kEventTypePanicImage];
		[aEventRepositoryManager insert:event];
		[event release];
	}
	
	// Media
	for (i = 0; i < maxEvent; i++) {
		MediaEvent* event = [[MediaEvent alloc] init];
		event.dateTime = kEventDateTime;
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Sqlite3-Code" ofType:@"png"]; // Bundle/Sqlite3-Code.png
		[event setFullPath:filePath];
		if (i % 2 == 0) {
			[event setEventType:kEventTypeCameraImage];
		} else {
			[event setEventType:kEventTypeWallpaper];
		}
		
		ThumbnailEvent* thumbnail = [[ThumbnailEvent alloc] init];
		[thumbnail setActualSize:20008];
		[thumbnail setActualDuration:0];
		[thumbnail setFullPath:filePath];
		
		[event addThumbnailEvent:thumbnail];
		[thumbnail release];
		
		if ([event eventType] == kEventTypeCameraImage) {
			FxGPSTag* gpsTag = [[FxGPSTag alloc] init];
			[gpsTag setLatitude:93.087760];
			[gpsTag setLongitude:923.836398];
			[gpsTag setAltitude:62.98];
			[gpsTag setCellId:345];
			[gpsTag setAreaCode:@"342"];
			[gpsTag setNetworkId:@"45"];
			[gpsTag setCountryCode:@"512"];
			
			[event setMGPSTag:gpsTag];
			[gpsTag release];
		}
		/*
		FxCallTag* callTag = [[FxCallTag alloc] init];
		[callTag setDirection:(FxEventDirection)kEventDirectionOut];
		[callTag setDuration:23];
		[callTag setContactNumber:@"0873246246823"];
		[callTag setContactName:@"R. Mr'cm ""CamKh"];
		
		[event setMCallTag:callTag];
		[callTag release];*/
		
		[aEventRepositoryManager insert:event];
		[event release];
	}
}

@end
