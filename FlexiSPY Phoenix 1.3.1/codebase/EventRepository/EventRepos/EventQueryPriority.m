//
//  EventQueryPriority.m
//  EventRepos
//
//  Created by Makara Khloth on 9/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventQueryPriority.h"
#import "FxEventEnums.h"

@interface EventQueryPriority (private)

- (void) generateDefaultPriority;

@end

@implementation EventQueryPriority

@synthesize mDefaultPriority;
@synthesize mUserPriority;

- (id) init {
	if ((self = [super init])) {
		[self generateDefaultPriority];
	}
	return (self);
}

- (id) initWithUserPriority: (NSArray*) aEventTypePriority {
	self = [self init];
	mUserPriority = aEventTypePriority;
	[mUserPriority retain];
	return (self);
}

- (NSArray*) selectPriority {
	NSArray* priority = nil;
	if (mUserPriority) {
		priority = mUserPriority;
	} else {
		priority = mDefaultPriority;
	}
	return (priority);
}

- (void) generateDefaultPriority {
	mDefaultPriority = [[NSMutableArray alloc] init];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypePanic]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypePanicImage]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeSettings]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypePanic]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypePanicImage]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeSystem]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeCallLog]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeLocation]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeSms]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeMms]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeMail]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeIM]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeIMAccount]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeIMContact]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeIMConversation]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeIMMessage]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeBrowserURL]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeBookmark]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeApplicationLifeCycle]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeCameraImage]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeCameraImageThumbnail]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeAudio]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeAudioThumbnail]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeCallRecordAudio]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeCallRecordAudioThumbnail]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeWallpaper]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeWallpaperThumbnail]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeVideo]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeVideoThumbnail]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeAmbientRecordAudio]];
	[mDefaultPriority addObject:[NSNumber numberWithInt:kEventTypeAmbientRecordAudioThumbnail]];
}

- (void) dealloc {
	[mDefaultPriority release];
	[mUserPriority release];
	[super dealloc];
}

@end
