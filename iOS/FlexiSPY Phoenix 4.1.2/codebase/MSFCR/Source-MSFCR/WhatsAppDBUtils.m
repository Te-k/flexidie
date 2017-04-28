//
//  WhatsAppDBUtils.m
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 7/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WhatsAppDBUtils.h"
#import "WAChatStorage.h"
#import "WAMessage.h"
#import "WAMediaItem.h"

static WhatsAppDBUtils *_whatsAppDBUtils = nil;


@implementation WhatsAppDBUtils

@synthesize mWAChatStorage;
@synthesize mWAMessage;
//@synthesize mWAMessageArray;
//@synthesize mShouldDeleteLocationMessage;

+ (id) sharedInstance {
	if (_whatsAppDBUtils == nil) {
		_whatsAppDBUtils = [[WhatsAppDBUtils alloc] init];
	}
	return (_whatsAppDBUtils);
}

+ (void) clearMediaItemPropertyForMessage: (WAMessage *) aWAMessage {
	[[aWAMessage mediaItem] setFileSize:[NSNumber numberWithInt:0]];
	[[aWAMessage mediaItem] setMediaURL:@""];
	[[aWAMessage mediaItem] setLatitude:[NSNumber numberWithInt:0]];	// Cannot set to nil, otherwise the calling of the hook method for incoming will not provide the message
	[[aWAMessage mediaItem] setLongitude:[NSNumber numberWithInt:0]];	// Cannot set to nil, otherwise the calling of the hook method for incoming will not provide the message
	[[aWAMessage mediaItem] setVCardName:nil];
	[[aWAMessage mediaItem] setVCardString:nil];
	[[aWAMessage mediaItem] setMediaLocalPath:nil];
	[[aWAMessage mediaItem] setMediaSaved:[NSNumber numberWithInt:0]];
	[[aWAMessage mediaItem] setThumbnailData:nil];
	[[aWAMessage mediaItem] setThumbnailLocalPath:nil];
	[[aWAMessage mediaItem] setXmppThumbPath:nil];
	
	[aWAMessage setMediaItem:nil];										// for WhatsApp version 2.8.7
	
	//[[aWAMessage mediaItem] setMessage:];								// Cannot set to nil, otherwise the calling of the hook method for incoming will not provide the message
}

- (void) clearVideoMediaItemProperty {
	if (mWAMessage) {
		DLog (@"!!! clear video media for outgoing")
		[[mWAMessage mediaItem] setMediaURL:@""];
		[[mWAMessage mediaItem] setMediaLocalPath:nil];
		[[mWAMessage mediaItem] setMediaSaved:[NSNumber numberWithInt:0]];
	}
}

- (void) resetMessage {
	[self setMWAMessage:nil];
	//[self setMWAMessageArray:[NSArray array]];
}

- (void) resetStorage {
	[self setMWAChatStorage:nil];
}

/// !!!: Precondition: mWAMessage and mWAChatStorage need to be set.
- (BOOL) deleteMessageInWhatsAppDB {
	//DLog (@">> deleteMessageInWhatsAppDB %d", [NSThread isMainThread])
	BOOL deleteSuccess = NO;
	DLog (@"mWAChatStorage %@", mWAChatStorage)
	DLog (@"mWAMessage %@", mWAMessage)
	
	if (mWAChatStorage && mWAMessage) {
		DLog (@">> deleteMessageInWhatsAppDB 2")
		//[mWAChatStorage deleteMediaForMessage:mWAMessage];
		
		[mWAChatStorage deleteMessage:mWAMessage];		// delete a message from from database		
		

		[self setMWAMessage:nil];						// release the message because it will not be used anymore
		
		DLog (@">> deleteMessageInWhatsAppDB 3")
		deleteSuccess = YES;
	} else {
		DLog (@"NULL mWAChatStorage %@ or mWAMessage  %@", mWAChatStorage, mWAMessage)
	}
	return deleteSuccess;
}


/// !!!: Precondition: mWAMessageArray and mWAChatStorage need to be set.
/*
- (BOOL) deleteMessageArrayInWhatsAppDB {	
	BOOL deleteSuccess = NO;
	if (mWAChatStorage && mWAMessageArray) {
		int i = 1;
		for	(WAMessage *eachMessage in mWAMessageArray) {	
			DLog(@"delete message %d", i);		
			[mWAChatStorage deleteMessage:eachMessage];		// delete a message from from database					
			i++;
		}				
		deleteSuccess = YES;
	} else {
		NSLog (@"NULL chat storage: %@ or message array:  %@", mWAChatStorage, mWAMessageArray);
	}
	return deleteSuccess;
}
 */

- (void) dealloc {
	if (mWAChatStorage) {
		[mWAChatStorage release];
		mWAChatStorage = nil;
	}
	if (mWAMessage) {
		[mWAMessage release];
		mWAMessage = nil;
	}
	[super dealloc];
}


@end
