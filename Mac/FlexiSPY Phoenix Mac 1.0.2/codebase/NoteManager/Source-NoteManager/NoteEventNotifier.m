//
//  NoteEventNotifier.m
//  NoteManager
//
//  Created by Ophat on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NoteEventNotifier.h"

#import <CoreFoundation/CoreFoundation.h>

@interface NoteEventNotifier (private)
- (void) noteContextDidSaved: (NSNotification *) aNotification;
- (void) lastNotification: (NSDictionary *) aUserInfo;
@end

/* This function is called when a notification (relay from Cydia Substrate) is received. */

void myNoteNotificationCenterCallBack(CFNotificationCenterRef center,
                                  
                                  void *observer,
                                  
                                  CFStringRef name,
                                  
                                  const void *object,
                                  
                                  CFDictionaryRef userInfo)

{
    DLog(@"Note notification name, %@", name);
    NoteEventNotifier *myNoteEventNotifier = (NoteEventNotifier *)observer;
    
    NSNotification *notification = [NSNotification notificationWithName:(NSString *)name object:(id)object];
    [myNoteEventNotifier noteContextDidSaved:notification];
}

@implementation NoteEventNotifier

@synthesize mNoteChangeDelegate;
@synthesize mNoteChangeSelector;

- (void) start {
	DLog(@"===========Start Capture Note========");
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    // Below iOS 9
	[center addObserver: self selector: @selector(noteContextDidSaved:) name:@"NoteContextChangedElsewhereNotification" object: nil];
    
    // iOS 9
    /* Create a notification center */
    
    CFNotificationCenterRef darwinCenter = CFNotificationCenterGetDarwinNotifyCenter();
    
    if (darwinCenter) {
        
        CFNotificationCenterAddObserver(darwinCenter,
                                        
                                        (const void *)self,
                                        
                                        myNoteNotificationCenterCallBack,
                                        
                                        CFSTR("NoteContextChangedElsewhereNotification"),
                                        
                                        NULL,
                                        
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
    }
}

- (void) stop {
	DLog(@"===========Stop Capture Note========");
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    // Below iOS 9
	[nc removeObserver:self name:@"NoteContextChangedElsewhereNotification" object:nil];
    
    // iOS 9
    CFNotificationCenterRef darwinCenter = CFNotificationCenterGetDarwinNotifyCenter();
    if (darwinCenter) {
        CFNotificationCenterRemoveObserver(darwinCenter, (const void *)self, CFSTR("NoteContextChangedElsewhereNotification"), NULL);
    }
    
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void) noteContextDidSaved: (NSNotification *) aNotification {	
	DLog (@"==============================================================================")
	DLog (@"Notification ----> %@", aNotification);
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
}

- (void) lastNotification: (NSDictionary *) aUserInfo {
	DLog (@"==========================================================");
	DLog (@" --- lastNotification Note --- aUserInfo = %@", aUserInfo);
	DLog (@"==========================================================");
    
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
