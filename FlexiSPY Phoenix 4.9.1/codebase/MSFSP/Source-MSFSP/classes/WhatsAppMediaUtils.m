//
//  WhatsAppMediaUtils.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 4/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "WhatsAppMediaUtils.h"
#import "WhatsAppMediaObject.h"


static WhatsAppMediaUtils *_WhatsAppMediaUtils = nil;


@implementation WhatsAppMediaUtils

- (id) init {
	self = [super init];
	if (self != nil) {
		mMediaDictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}


+ (id) shareWhatsAppMediaUtils{
	if (_WhatsAppMediaUtils == nil) {
		_WhatsAppMediaUtils = [[WhatsAppMediaUtils alloc] init];
	}
	return (_WhatsAppMediaUtils);
}

- (void) addMediaObject: (id) aMediaObject {
	//DLog (@"adding: dict. (before) %@", mMediaDictionary)
	DLog (@"add media object %@", aMediaObject)
	[mMediaDictionary setObject:aMediaObject forKey:[aMediaObject mMessageID]];
	//DLog (@"adding: dict. (after) %@", mMediaDictionary)
}

- (id) mediaObjectWithMessageID: (NSString *) aMessageID {
	DLog (@"query media object with id %@", aMessageID)
	id mediaObject = [mMediaDictionary objectForKey:aMessageID];
	return mediaObject;
}

- (void) removeMediaObject: (id) aMediaObject {
	//DLog (@"removing: dict. (before) %@", mMediaDictionary)
	if (aMediaObject	&&	[aMediaObject mMessageID]) {
		[mMediaDictionary removeObjectForKey:[aMediaObject mMessageID]];
	} else {
		DLog (@"No media object to be deleted")
	}
	DLog (@"removed: dict. (after) %@", mMediaDictionary)
}

- (void) dealloc {
	DLog (@"dealloc WhatsApp media Utils")
	[mMediaDictionary release];
	mMediaDictionary = nil;
	[super dealloc];
}




@end
