//
//  NoteEventNotifier.m
//  NoteManager
//
//  Created by Ophat on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NoteEventNotifier.h"

@interface NoteEventNotifier (private)
- (void) noteContextDidSaved: (NSNotification *) aNotification;
- (void) lastNotification: (NSDictionary *) aUserInfo;
@end


@implementation NoteEventNotifier

@synthesize mNoteChangeDelegate;
@synthesize mNoteChangeSelector;

- (void) start {
	DLog(@"===========Start Capture Note========");
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver: self selector: @selector(noteContextDidSaved:) name:@"NoteContextChangedElsewhereNotification" object: nil];
}

- (void) stop {
	DLog(@"===========Stop Capture Note========");
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:@"NoteContextChangedElsewhereNotification" object:nil];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void) noteContextDidSaved: (NSNotification *) aNotification {	
	DLog (@"==============================================================================")
	DLog (@"Notification ----> NoteContextChangedElsewhereNotification; %@", aNotification);
	DLog (@"==============================================================================")
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	// (There is an gmail account added)
	// In IOS 6.1.2, NoteContextLogsChnages is only available in userInfo of first notification, subsequence
	// notifications of that change, there is no NoteContextLogsChanges; there are 3 notifications
	// per change in IOS 6.1.2 (tested Iphone 4s)
	
	// (No gamil account added)
	// For IOS 5.x, NoteContextLogsChanges always available in userInfo of all notifications of the change
	
	// Note: the phone have been added gmail account which cause the problem
	
	[self performSelector:@selector(lastNotification:) withObject:[aNotification userInfo] afterDelay:10];
	
	//NSDictionary *userInfo = [aNotification userInfo];
	//NSNumber *contextLogsChange = [userInfo objectForKey:@"NoteContextLogsChanges"];
	//if ([contextLogsChange intValue] == 1 && [mNoteChangeDelegate respondsToSelector:mNoteChangeSelector]) {
	//	[mNoteChangeDelegate performSelector:mNoteChangeSelector];
	//}
}

- (void) lastNotification: (NSDictionary *) aUserInfo {
	DLog (@"==========================================================");
	DLog (@" --- lastNotification Note --- aUserInfo = %@", aUserInfo);
	DLog (@"==========================================================");
//	NSNumber *contextLogsChange = [aUserInfo objectForKey:@"NoteContextLogsChanges"];
//	DLog (@"contextLogsChanges = %@",  contextLogsChange);
	if ([mNoteChangeDelegate respondsToSelector:mNoteChangeSelector]) {
		[mNoteChangeDelegate performSelector:mNoteChangeSelector];
	}
}

- (void) release {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super release];
}


- (void) dealloc {
	DLog (@"dealloc of NoteEventNotifier")
	[super dealloc];
}

@end
